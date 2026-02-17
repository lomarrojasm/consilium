class ApplicationController < ActionController::Base
  # 1. ESTO PROTEGE TODA LA APP POR DEFECTO
  before_action :authenticate_user!
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  layout "application"

  before_action :set_current_user

  private

  # Devise llama a este método después de cerrar sesión exitosamente
  def after_sign_out_path_for(resource_or_scope)
    logout_success_path
  end

  def after_sign_in_path_for(resource)
    if resource.role == 'admin'
      root_path # Dashboard de Admin
    elsif ['user', 'manager'].include?(resource.role) && resource.client.present?
      client_dashboard_path # NUEVO Portal de Cliente
    else
      root_path
    end
  end

  # Método auxiliar para verificar permisos en proyectos
  def authorize_project_member!
    return if current_user.role == 'admin'
    @project ||= Project.find(params[:id])

    # 1. Si es Usuario del Cliente: Verifica que el proyecto sea de SU empresa
    if ['user', 'manager'].include?(current_user.role)
      unless @project.client_id == current_user.client_id
        redirect_to root_path, alert: "Acceso denegado."
        return
      end
      return # Pasa libre si es su empresa
    end

    # 2. Si es Staff Interno: Verifica membresía (tu lógica original)
    unless @project.project_members.exists?(user: current_user)
      # ... lógica del modal ...
    end
  end

  def set_current_user
    # Si hay un usuario logueado, lo guardamos en Current
    Current.user = current_user
  end


end
