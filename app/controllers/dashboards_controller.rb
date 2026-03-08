class DashboardsController < ApplicationController
  before_action :authenticate_user!
  # Usa el método authorize_admin! de ApplicationController (compatible con Pretender)
  before_action :authorize_admin!

  def index
    @total_clients = Client.count
    @total_users = User.count
    @pending_invites = User.where(invitation_accepted_at: nil).where.not(invitation_token: nil).count
    @active_projects = Project.where(status: 'activo').count

    @recent_users = User.order(created_at: :desc).limit(5)
    # @recent_activities = PublicActivity::Activity.order(created_at: :desc).limit(10)
  end
  
  def analytics; end
  def crm; end

  def projects
    @total_clients = Client.count
    @total_users = User.count
    @pending_invites = User.where(invitation_accepted_at: nil).where.not(invitation_token: nil).count
    @active_projects = Project.where(status: 'activo').count

    @recent_users = User.order(created_at: :desc).limit(5)
    @new_registrations = User.order(created_at: :desc).limit(6) 

    @completed_count = Activity.where(completed: true).count
    @pending_count   = Activity.where(completed: false).count
    @total_activities = @completed_count + @pending_count

    @clients = Client.joins(:projects)
                    .group("clients.id", "clients.company_name")
                    .order("clients.company_name ASC")
    
    @client_names = @clients.pluck(:company_name)

    @data_borrador   = @clients.map { |c| c.projects.where(status: 'borrador').count }
    @data_activo     = @clients.map { |c| c.projects.where(status: 'activo').count }
    @data_pausado    = @clients.map { |c| c.projects.where(status: 'pausado').count }
    @data_finalizado = @clients.map { |c| c.projects.where(status: 'finalizado').count }
  end

  def wallet; end
end