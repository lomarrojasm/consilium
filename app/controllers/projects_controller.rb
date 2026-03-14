class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client
  
  # Añadimos todas las acciones sensibles que requieren validar si el usuario es miembro
  before_action :set_client_and_project, only: [
    :show, :edit, :update, :destroy, :delete_file, 
    :schedule_view, :toggle_activity, :comments
  ]
  
  # SEGURIDAD: Ahora 'show' y 'comments' también están protegidos
  before_action :authorize_project_member!, only: [
    :show, :edit, :update, :destroy, :toggle_activity, :delete_file, :comments
  ]

  def index
    # Solo mostramos los proyectos donde el usuario es miembro (si no es admin)
    if current_user.role == 'admin'
      @projects = @client.projects.order(created_at: :desc)
    else
      @projects = @client.projects.joins(:project_members)
                                 .where(project_members: { user_id: current_user.id })
                                 .order(created_at: :desc).distinct
    end
  end

  def show
    # 1. LOGICA DEL TIMELINE (Corregido ILIKE a LIKE para MySQL)
    @events = TimelineLog.where(resource_id: @project.id)
                        .or(TimelineLog.where(resource_type: 'ProjectMember', resource_id: @project.project_members.pluck(:id)))
                        .or(TimelineLog.where(resource_type: 'Activity', resource_id: @project.stages.flat_map(&:activities).pluck(:id)))
                        .or(TimelineLog.where(resource_type: 'ProjectComment', resource_id: @project.comments.pluck(:id)))
                        .order(happened_at: :desc)

    if params[:q].present?
      @events = @events.where("details LIKE ?", "%#{params[:q]}%")
    end

    @stages = @project.stages.includes(activities: :responsible)
    @comments = @project.comments.order(created_at: :desc)
    @comment = ProjectComment.new 

    current_member_ids = @project.users.pluck(:id)
    @eligible_users = User.where(client_id: @client.id)
                          .or(User.where(role: 'admin'))
                          .where.not(id: current_member_ids)
  end

  def new
    @project = @client.projects.build
    @eligible_users = User.where(client_id: @client.id).order(:first_name)
  end

  def create
    @project = @client.projects.build(project_params)
    @project.user = current_user
    
    if @project.save
      # 1. Asignación del responsable como líder del proyecto
      if @project.responsible_id.present?
        @project.project_members.find_or_create_by(user_id: @project.responsible_id, role: 'lider')
      end

      # 2. Generación de la plantilla si el usuario marcó la casilla
      if params[:project][:include_template] == "1"
        # Aquí inyectamos el params[:template_year] que viene del nuevo select en la vista
        ConsiliumTemplateService.generate_structure(@project, current_user, params[:template_year])
      end

      redirect_to client_project_path(@client, @project), notice: 'Proyecto iniciado correctamente.'
    else
      # 3. Manejo de errores: Recargamos los usuarios para que el formulario (select) no falle
      @eligible_users = User.where(client_id: @client.id).order(:first_name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @eligible_users = User.where(client_id: @client.id).order(:first_name)
  end
  
  def update
    if params[:project][:files].present?
      uploaded_files = params[:project][:files].reject(&:blank?)
      if uploaded_files.any?
        @project.files.attach(uploaded_files)
        # Mantenemos tu lógica de logs original
        TimelineLog.create(
          client: @client, user: current_user, resource: @project, resource_name: @project.name,
          action_type: 'update', details: "📂 Se adjuntaron: #{uploaded_files.map(&:original_filename).join(', ')}",
          happened_at: Time.current
        )
      end
    end

    if @project.update(project_params.except(:files))
      if @project.saved_change_to_responsible_id? && @project.responsible_id.present?
        @project.project_members.find_or_create_by(user_id: @project.responsible_id, role: 'lider')
      end
      redirect_to client_project_path(@client, @project), notice: "Proyecto actualizado exitosamente."
    else
      @eligible_users = User.where(client_id: @client.id).order(:first_name)
      render :edit, status: :unprocessable_entity
    end
  end

  def delete_file
    @file = ActiveStorage::Attachment.find(params[:attachment_id])
    file_name = @file.filename.to_s
    @file.purge

    TimelineLog.create(
      client: @client, user: current_user, resource: @project, resource_name: @project.name,
      action_type: 'update', details: "🗑️ Se eliminó el archivo: #{file_name}",
      happened_at: Time.current
    )
    redirect_to client_project_path(@client, @project), notice: "Archivo eliminado."
  end

  def destroy
    @project.destroy
    redirect_to client_path(@client), notice: 'Proyecto eliminado.'
  end

  def toggle_activity
    @activity = Activity.find(params[:activity_id])
    new_status = !@activity.completed
    @activity.update(completed: new_status, completed_day: (new_status ? Time.current.day : nil))
    
    redirect_back fallback_location: client_project_path(@client, @project), notice: "Estatus de tarea actualizado."
  end

  def schedule_view
    @stages = @project.stages.includes(activities: :responsible).order(:id)
  end

  def comments
    @comments = @project.comments.order(created_at: :desc)
    if params[:comment_query].present?
      @comments = @comments.where("body LIKE ?", "%#{params[:comment_query]}%")
    end
    @new_comment = ProjectComment.new 
  end

  private

  # SEGURIDAD: Evita que un usuario vea clientes que no le corresponden
  def set_client
    if true_user.role == 'admin'
      @client = Client.find(params[:client_id])
    else
      @client = current_user.client
      # Si intentan acceder a otro ID de cliente por URL, los expulsamos
      if params[:client_id].to_i != @client.id
        redirect_to root_path, alert: "Acceso no autorizado a este cliente."
      end
    end
  end

  def set_client_and_project
    @project = @client.projects.find(params[:id] || params[:project_id])
  end

  def project_params
    params.require(:project).permit(:name, :start_date, :end_date, :budget, :status, :details, :include_template, :responsible_id, :sequential_stages, files: [])
  end
  
  # SEGURIDAD: Bloquea el acceso a proyectos específicos si no eres miembro
  def authorize_project_member!
    unless true_user.role == 'admin' || @project.users.include?(current_user)
      redirect_to client_path(@client), alert: "No tienes permiso para acceder a este proyecto."
    end
  end
end