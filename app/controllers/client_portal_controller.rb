class ClientPortalController < ApplicationController
  before_action :authenticate_user!
  # El filtro asegura que solo usuarios con empresa o admins reales entren
  before_action :ensure_client_access!

  def index
    # Con Pretender, si impersonamos, current_user es el cliente.
    # El portal se centra en la empresa de ese usuario.
    @client = current_user.client

    # --- LÓGICA DE PROYECTOS (Filtrado por Rol) ---
    if @client
      if current_user.role == 'admin' || current_user.role == 'manager'
        # El Admin (impersonando) o el Manager de la empresa ven todo lo de su cliente.
        @projects = @client.projects
      else 
        # ROL: USER - Solo ve proyectos donde es miembro específico.
        @projects = @client.projects
                           .joins(:project_members)
                           .where(project_members: { user_id: current_user.id })
                           .group("projects.id") # MySQL requiere agrupamiento por ID
      end
    else
      # Si un admin entra directo sin estar asignado a un cliente ni impersonar
      @projects = true_user.role == 'admin' ? Project.all : Project.none
    end

    # --- LÓGICA DE COMUNICACIÓN (Seguridad de Chat) ---
    if @client
      # Solo usuarios de la misma empresa para mantener la privacidad
      @available_users = @client.users.where.not(id: current_user.id).where(active: true)
      
      # Conversaciones donde participa el usuario actual (impersonado o real)
      @conversations = Conversation.where(client_id: @client.id) # Blindaje por empresa
                                 .and(
                                   Conversation.where(sender_id: current_user.id)
                                   .or(Conversation.where(recipient_id: current_user.id))
                                 )
                                 .includes(:sender, :recipient)
    else
      @available_users = []
      @conversations = []
    end

    # Carga optimizada y ordenamiento compatible con MySQL
    @projects = @projects.includes(:stages).order("projects.start_date ASC")

    # Datos para gráficas (Progress Tracking)
    @projects_labels = @projects.map(&:name)
    @projects_progress = @projects.map(&:progress_percentage)
  end

  private

  def ensure_client_access!
    # Permitimos el paso si es el Admin real (true_user) aunque esté impersonando
    return if true_user.role == 'admin'

    # Un usuario normal debe tener una empresa asignada para entrar al portal
    unless current_user.client_id.present? && ['user', 'manager'].include?(current_user.role)
      redirect_to root_path, alert: "No tienes los permisos necesarios para acceder al portal de clientes."
    end
  end
end