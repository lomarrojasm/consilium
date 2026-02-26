class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client
  before_action :set_client_and_project, only: [
    :show, :edit, :update, :destroy, :delete_file, 
    :schedule_view, :toggle_activity, :comments
  ]
  
  before_action :authorize_project_member!, only: [:edit, :update, :destroy, :toggle_activity]

  def index
    @projects = @client.projects.order(created_at: :desc)
  end

  def show
    # 1. LOGICA DEL TIMELINE
    @events = TimelineLog.where(resource_id: @project.id)
                        .or(TimelineLog.where(resource_type: 'ProjectMember', resource_id: @project.project_members.pluck(:id)))
                        .or(TimelineLog.where(resource_type: 'Activity', resource_id: @project.stages.flat_map(&:activities).pluck(:id)))
                        .or(TimelineLog.where(resource_type: 'ProjectComment', resource_id: @project.comments.pluck(:id)))
                        .order(happened_at: :desc)

    if params[:q].present?
      @events = @events.where("details ILIKE ?", "%#{params[:q]}%")
    end

    # 2. CARGA DE DATOS
    @stages = @project.stages.includes(activities: :responsible)
    @comments = @project.comments.order(created_at: :desc)
    @comment = ProjectComment.new 

    # 3. MIEMBROS ELEGIBLES (Solo usuarios de la empresa del cliente o admins)
    # Excluimos a los que ya son miembros
    current_member_ids = @project.users.pluck(:id)
    @eligible_users = User.where(client_id: @client.id)
                          .or(User.where(role: 'admin'))
                          .where.not(id: current_member_ids)
  end

  def new
    @project = @client.projects.build
    # Para el selector del responsable en New
    @eligible_users = User.where(client_id: @client.id).order(:first_name)
  end

  def create
    @project = @client.projects.build(project_params)
    @project.user = current_user
    
    if @project.save
      # A. AGREGAR AL RESPONSABLE COMO MIEMBRO AUTOMÁTICAMENTE
      if @project.responsible_id.present?
        @project.project_members.find_or_create_by(user_id: @project.responsible_id, role: 'lider')
      end

      # B. CARGAR METODOLOGÍA
      if params[:project][:include_template] == "1"
        ConsiliumTemplateService.generate_structure(@project, current_user)
      end

      # C. REDIRECCIÓN AL SHOW
      redirect_to client_project_path(@client, @project), notice: 'Proyecto iniciado correctamente.'
    else
      @eligible_users = User.where(client_id: @client.id).order(:first_name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @eligible_users = User.where(client_id: @client.id).order(:first_name)
  end
  
  def update
    # Manejo de archivos adjuntos (Mantiene tu lógica original)
    if params[:project][:files].present?
      uploaded_files = params[:project][:files].reject(&:blank?)
      if uploaded_files.any?
        @project.files.attach(uploaded_files)
        TimelineLog.create(
          client: @client, user: current_user, resource: @project, resource_name: @project.name,
          action_type: 'update', details: "📂 Se adjuntaron: #{uploaded_files.map(&:original_filename).join(', ')}",
          happened_at: Time.current
        )
      end
    end

    if @project.update(project_params.except(:files))
      # Al actualizar el responsable, también nos aseguramos de que sea miembro
      if @project.saved_change_to_responsible_id? && @project.responsible_id.present?
        @project.project_members.find_or_create_by(user_id: @project.responsible_id, role: 'lider')
      end

      # REDIRECCIÓN AL SHOW (Cambio solicitado)
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
    # @project y @client ya están cargados por el before_action (set_client_and_project)
    
    # 1. Cargamos los comentarios existentes
    @comments = @project.comments.order(created_at: :desc)
    
    # 2. Filtro de búsqueda si existe
    if params[:comment_query].present?
      @comments = @comments.where("body ILIKE ?", "%#{params[:comment_query]}%")
    end

    # 3. ESTA ES LA LÍNEA CLAVE: Inicializar el objeto para el formulario
    # Debe llamarse EXACTAMENTE igual que en la vista
    @new_comment = ProjectComment.new 
  end

  private

  def set_client
    @client = Client.find(params[:client_id])
  end

  def set_client_and_project
    @project = @client.projects.find(params[:id] || params[:project_id])
  end

  # Se incluye responsible_id en los parámetros permitidos
  def project_params
    params.require(:project).permit(:name, :start_date, :end_date, :budget, :status, :details, :include_template, :responsible_id, files: [])
  end
  
  def authorize_project_member!
    unless current_user.role == 'admin' || @project.users.include?(current_user)
      redirect_to client_path(@client), alert: "No tienes permiso para realizar esta acción."
    end
  end
end