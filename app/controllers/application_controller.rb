class ApplicationController < ActionController::Base
  # 1. CONFIGURACIÓN Y PROTECCIÓN GLOBAL
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_user

  # EXPOSICIÓN A VISTAS: Permite usar estos métodos en cualquier .html.erb
  helper_method :current_project_role

  allow_browser versions: :modern
  layout "application"

  private

  # =========================================================================
  # 2. SEGURIDAD DE ACCESO (ADMINISTRACIÓN Y PROYECTOS)
  # =========================================================================

  # Solo permite el paso a usuarios con rol 'admin' (Global)
  def authorize_admin!
    unless current_user&.role == 'admin'
      redirect_to root_path, alert: "Acceso denegado: Solo administradores pueden gestionar esta sección."
    end
  end

  # Identifica el rol operativo dentro de un proyecto específico
  def current_project_role
    return 'admin' if current_user&.role == 'admin'
    
    project_id = params[:project_id] || params[:id]
    return nil unless project_id

    @current_project_role ||= begin
      project = Project.find_by(id: project_id)
      return nil unless project

      # Buscamos la membresía específica del usuario en este proyecto
      membership = project.project_members.find_by(user: current_user)
      
      if membership
        membership.role # lider, senior, analista, espectador
      elsif ['user', 'manager'].include?(current_user.role) && project.client_id == current_user.client_id
        'espectador' # Usuarios de cliente ven sus propios proyectos como espectadores por defecto
      else
        nil
      end
    end
  end

  # Filtros para controladores de proyectos
  def authorize_project_member!
    if current_project_role.nil?
      redirect_to root_path, alert: "No tienes permiso para acceder a este proyecto."
    end
  end

  def authorize_lider_or_senior!
    unless ['admin', 'lider', 'senior'].include?(current_project_role)
      redirect_to root_path, alert: "Tu rol actual no permite realizar esta acción operativa."
    end
  end

  # =========================================================================
  # 3. CONFIGURACIÓN DE DEVISE E INVITACIONES
  # =========================================================================

  def after_sign_in_path_for(resource)
    resource.role == 'admin' ? root_path : client_dashboard_path
  end

  def after_sign_out_path_for(resource_or_scope)
    logout_success_path
  end

  def configure_permitted_parameters
    # Lista exhaustiva para no perder funcionalidad de invitaciones y seguimiento
    full_keys = [
      :email, :encrypted_password, :first_name, :last_name, :username, 
      :job_title, :role, :active, :client_id, :reset_password_token, 
      :reset_password_sent_at, :remember_created_at, :sign_in_count, 
      :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, 
      :last_sign_in_ip, :invitation_token, :invitation_created_at, 
      :invitation_sent_at, :invitation_accepted_at, :invitation_limit, 
      :invited_by_id, :invited_by_type, :created_at, :updated_at, :avatar, :phone
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