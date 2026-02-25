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
    # Métricas principales
    @total_clients = Client.count
    @total_users = User.count
    @pending_invites = User.where(invitation_accepted_at: nil).where.not(invitation_token: nil).count
    @active_projects = 12 # Aquí podrías poner Project.where(active: true).count si tienes el modelo

    # Datos para las tablas y el timeline
    @recent_users = User.order(created_at: :desc).limit(5)
    @new_registrations = User.order(created_at: :desc).limit(6) # Para el timeline de actividad

    # Contamos usando el campo booleano 'completed'
  @completed_count = Activity.where(completed: true).count
  @pending_count   = Activity.where(completed: false).count
  
  @total_activities = @completed_count + @pending_count
  
  # Si quieres mantener una tercera categoría como "Sin asignar", 
  # podrías contar las que no tienen user_id, por ejemplo:
  # @unassigned_count = Activity.where(user_id: nil).count

  # Agrupamos los proyectos por el nombre del cliente
  # Nota: Asume que Client tiene una relación has_many :projects
  @projects_per_client = Client.joins(:projects)
                               .group('clients.company_name')
                               .count
  
  @client_names = @projects_per_client.keys
  @project_counts = @projects_per_client.values


  end

  def wallet
  end

  private

  def authorize_admin!
    redirect_to root_path, alert: "Acceso denegado" unless current_user.admin?
  end

end
