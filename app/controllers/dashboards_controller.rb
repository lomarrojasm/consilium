class DashboardsController < ApplicationController
  # 1. OBLIGAR AUTENTICACIÓN
  # Si el usuario no está logueado, Devise lo redirige al Login automáticamente.
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    # Estadísticas Globales
    @total_clients = Client.count
    @total_users = User.count
    @pending_invites = User.where(invitation_accepted_at: nil).where.not(invitation_token: nil).count
    @active_projects = Project.where(status: 'active').count # Ajusta según tu modelo

    # Listados para las tablas
    @recent_users = User.order(created_at: :desc).limit(5)
    @recent_activities = PublicActivity::Activity.order(created_at: :desc).limit(10) # Si usas la gema public_activity
  end
  
  def analytics
  end

  def crm
  end

  def projects
  # 1. Métricas principales
  @total_clients = Client.count
  @total_users = User.count
  @pending_invites = User.where(invitation_accepted_at: nil).where.not(invitation_token: nil).count
  @active_projects = Project.where(status: 'activo').count # Basado en tus estados reales

  # 2. Datos para las tablas y el timeline
  @recent_users = User.order(created_at: :desc).limit(5)
  @new_registrations = User.order(created_at: :desc).limit(6) 

  # 3. Datos para la gráfica de Pastel (Activities)
  @completed_count = Activity.where(completed: true).count
  @pending_count   = Activity.where(completed: false).count
  @total_activities = @completed_count + @pending_count

  # 4. Datos para la gráfica de Barras Apiladas (Proyectos por Cliente)
  # Usamos group("clients.id") para evitar el error de MySQL con DISTINCT
  @clients = Client.joins(:projects)
                   .group("clients.id", "clients.company_name")
                   .order("clients.company_name ASC")
  
  @client_names = @clients.pluck(:company_name)

  # Mapeo de datos por estado para cada cliente
  # Nota: Esto genera varias consultas, funciona bien para volúmenes moderados
  @data_borrador   = @clients.map { |c| c.projects.where(status: 'borrador').count }
  @data_activo     = @clients.map { |c| c.projects.where(status: 'activo').count }
  @data_pausado    = @clients.map { |c| c.projects.where(status: 'pausado').count }
  @data_finalizado = @clients.map { |c| c.projects.where(status: 'finalizado').count }
end

  def wallet
  end

  private

  def authorize_admin!
    redirect_to root_path, alert: "Acceso denegado" unless current_user.admin?
  end

end
