class ClientPortalController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_client_access!

  def index
    # Verificamos si existe el cliente para evitar errores con Admins globales
    @client = current_user.client

    if current_user.role == 'admin'
      # Admin ve todo
      @projects = @client ? @client.projects : Project.all

    elsif current_user.role == 'manager'
      # Manager ve todo lo de su empresa
      @projects = @client.projects

    else 
      # ROL: USER (Aquí estaba el error)
      # Usamos .group(:id) en lugar de .distinct
      @projects = @client.projects
                         .joins(:project_members)
                         .where(project_members: { user_id: current_user.id })
                         .group(:id) 
    end

    # 1. Usuarios disponibles para iniciar chat (excluyendo al usuario actual)
    #    Si es Admin global (sin cliente), no cargamos usuarios o cargamos todos.
    if @client
      @available_users = @client.users.where.not(id: current_user.id)
      
      # 2. Conversaciones existentes donde el usuario participa (Enviadas o Recibidas)
      #    Asumiendo que tu modelo es Conversation(sender_id, recipient_id, client_id)
      @conversations = Conversation.where(sender_id: current_user.id)
                                 .or(Conversation.where(recipient_id: current_user.id))
                                 .includes(:sender, :recipient) # Para evitar N+1 queries
    else
      @available_users = []
      @conversations = []
    end

    # Aplicamos el orden y la carga optimizada al final
    # Nota: Aseguramos que el orden sea explícito sobre la tabla projects
    @projects = @projects.includes(:stages).order("projects.start_date ASC")

    # Datos para gráficas
    @projects_labels = @projects.map(&:name)
    @projects_progress = @projects.map(&:progress_percentage)
  end

  private

  def ensure_client_access!
    return if current_user.role == 'admin'
    unless current_user.client_id.present? && ['user', 'manager'].include?(current_user.role)
      redirect_to root_path, alert: "No tienes acceso al portal."
    end
  end
end