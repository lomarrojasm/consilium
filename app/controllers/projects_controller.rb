class ProjectsController < ApplicationController
  before_action :authenticate_user!
  
  # 1. Primero cargamos el cliente (necesario para todo)
  before_action :set_client

  # 2. Cargamos el proyecto SOLAMENTE UNA VEZ para las acciones que lo requieren
  # Nota: He unificado todo aquí. Eliminé 'set_project' para evitar conflictos.
  before_action :set_client_and_project, only: [
    :show, 
    :edit, 
    :update, 
    :destroy, 
    :delete_file, 
    :schedule_view, 
    :toggle_activity, # <--- Asegúrate de que estas acciones usen set_client_and_project
    :comments
  ]
  
  # 3. Autorización (opcional, si lo usas)
  before_action :authorize_project_member!, only: [:edit, :update, :destroy, :toggle_activity]

  # --- TUS ACCIONES ---

  def index
    @projects = @client.projects.order(created_at: :desc)
  end

  def show
    # @project y @client ya están definidos por set_client_and_project
  
    # 1. LOGICA DEL TIMELINE Y BÚSQUEDA
    @events = TimelineLog.where(resource_id: @project.id)
                        .or(TimelineLog.where(resource_type: 'ProjectMember', resource_id: @project.project_members.pluck(:id)))
                        .or(TimelineLog.where(resource_type: 'Activity', resource_id: @project.stages.flat_map(&:activities).pluck(:id)))
                        .or(TimelineLog.where(resource_type: 'ProjectComment', resource_id: @project.comments.pluck(:id))) # Agregamos comentarios al timeline
                        .order(happened_at: :desc)

    if params[:q].present?
      termino = "%#{params[:q]}%"
      @events = @events.where("details ILIKE ?", termino)
    end

    # 2. CARGA DE DATOS RELACIONADOS
    @stages = @project.stages.includes(:activities)
    
    # 3. BITÁCORA (Comentarios)
    @comments = @project.comments.order(created_at: :desc)
    
    # Buscador específico de comentarios
    if params[:comment_query].present?
      @comments = @comments.where("body LIKE ?", "%#{params[:comment_query]}%")
    end

    # IMPORTANTE: Inicializamos el objeto vacío para el formulario de "Nuevo Comentario"
    @comment = ProjectComment.new 

    # 4. MIEMBROS ELEGIBLES (Para agregar gente al equipo)
    @eligible_users = (User.where(client_id: @client.id).or(User.where(role: 'admin'))) - @project.users
  end

  def new
    @project = @client.projects.build
  end

  def create
    @project = @client.projects.build(project_params)
    @project.user = current_user
    
    if @project.save
      if project_params[:include_template] == "1"
        ConsiliumTemplateService.generate_structure(@project, current_user)
      end
      redirect_to client_project_path(@client, @project), notice: 'Proyecto iniciado correctamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end
  
  def update
    # Lógica de Archivos
    if params[:project][:files].present?
      uploaded_files = params[:project][:files].reject(&:blank?)

      if uploaded_files.any?
        @project.files.attach(uploaded_files)
        nombres_archivos = uploaded_files.map(&:original_filename).join(', ')

        TimelineLog.create(
          client: @client,
          user: current_user,
          resource: @project,
          action_type: 'update',
          details: "📂 Se adjuntaron: #{nombres_archivos}",
          happened_at: Time.current
        )
      end
    end

    if @project.update(project_params.except(:files))
      redirect_back fallback_location: root_path, notice: "Proyecto actualizado."
    else
      render :show
    end
  end

  def delete_file
    @file = ActiveStorage::Attachment.find(params[:attachment_id])
    file_name = @file.filename.to_s
    @file.purge

    TimelineLog.create(
      client: @client,
      user: current_user,
      resource: @project,
      action_type: 'update',
      details: "🗑️ Se eliminó el archivo: #{file_name}",
      happened_at: Time.current
    )

    redirect_back fallback_location: root_path, notice: "Archivo eliminado."
  end

  def destroy
    @project.destroy
    redirect_to client_path(@client), notice: 'Proyecto eliminado.'
  end

  # Acción para marcar actividades (Toggle)
  def toggle_activity
    @activity = Activity.find(params[:activity_id])
    
    # Toggle y lógica de fecha completada
    new_status = !@activity.completed
    @activity.completed = new_status
    @activity.completed_day = new_status ? Time.current.day : nil # Guardamos el día si se completa
    @activity.save
    
    redirect_back fallback_location: client_project_path(@client, @project), notice: "Estatus actualizado."
  end

  # Vista de Cronograma (Schedule)
  def schedule_view
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:id])
    @stages = @project.stages.includes(:activities).order(:id)
  end

  # GET /clients/:client_id/projects/:id/comments
  # 2. DEFINIR LA ACCIÓN (Al final, antes de private)
  def comments
    # @project y @client ya están cargados por el before_action
    
    # Cargar comentarios ordenados
    @comments = @project.comments.order(created_at: :desc)
    
    # Lógica del buscador de la bitácora
    if params[:comment_query].present?
      @comments = @comments.where("body ILIKE ?", "%#{params[:comment_query]}%")
    end

    # Inicializar objeto para el formulario de nuevo comentario
    @new_comment = ProjectComment.new 
    
    # Inicializar variable para el formulario (por si usas @comment en la vista)
    @comment = @new_comment 
  end

  private

  def set_client
    @client = Client.find(params[:client_id])
  end

  def set_client_and_project
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:id] || params[:project_id])
  end

  def project_params
    params.require(:project).permit(:name, :start_date, :end_date, :budget, :status, :details, :include_template, files: [])
  end
  
  # Este método autoriza si el usuario puede editar
  def authorize_project_member!
    unless current_user.role == 'admin' || @project.users.include?(current_user)
      redirect_to client_path(@client), alert: "No tienes permiso para editar este proyecto."
    end
  end
end