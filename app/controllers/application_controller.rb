class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_user

  helper_method :current_project_role

  # Habilita Pretender (Impersonation)
  impersonates :user

  allow_browser versions: :modern
  layout "application"

  private

  # =========================================================================
  # SEGURIDAD GLOBAL: authorize_admin!
  # =========================================================================
  # Usamos true_user para que el Admin real pueda navegar aunque esté 
  # impersonando a un cliente.
  def authorize_admin!
    unless true_user&.role == 'admin'
      respond_to do |format|
        format.html { redirect_to root_path, alert: "No tienes permisos para acceder a esta sección." }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.append("body", partial: "shared/modal_access_denied") 
        }
      end
    end
  end

  def current_project_role
    return 'admin' if current_user&.role == 'admin'
    
    project_id = params[:project_id] || params[:id]
    return nil unless project_id

    @current_project_role ||= begin
      project = Project.find_by(id: project_id)
      return nil unless project
      membership = project.project_members.find_by(user: current_user)
      
      if membership
        membership.role 
      elsif ['user', 'manager'].include?(current_user.role) && project.client_id == current_user.client_id
        'espectador'
      else
        nil
      end
    end
  end

  def authorize_project_member!
    redirect_to root_path, alert: "No tienes permiso para acceder a este proyecto." if current_project_role.nil?
  end

  def authorize_lider_or_senior!
    unless ['admin', 'lider', 'senior'].include?(current_project_role)
      redirect_to root_path, alert: "Tu rol actual no permite realizar esta acción operativa."
    end
  end

  def after_sign_in_path_for(resource)
    resource.role == 'admin' ? root_path : client_dashboard_path
  end

  def after_sign_out_path_for(resource_or_scope)
    logout_success_path
  end

  def configure_permitted_parameters
    full_keys = [
      :email, :first_name, :last_name, :job_title, :role, :active, :client_id, :avatar, :phone
    ]
    devise_parameter_sanitizer.permit(:sign_up, keys: full_keys)
    devise_parameter_sanitizer.permit(:account_update, keys: full_keys)
    devise_parameter_sanitizer.permit(:invite, keys: full_keys)
    devise_parameter_sanitizer.permit(:accept_invitation, keys: full_keys)
  end

  def set_current_user
    Current.user = current_user if user_signed_in?
  end
end