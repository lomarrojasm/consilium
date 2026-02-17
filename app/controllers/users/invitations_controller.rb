class Users::InvitationsController < Devise::InvitationsController
  before_action :configure_permitted_parameters

  # GET /resource/invitation/new
  def new
    # Capturamos el client_id de la URL para pre-llenar el formulario
    self.resource = resource_class.new(client_id: params[:client_id])
    render :new
  end

  # POST /resource/invitation
  def create
    # Lógica estándar de Devise, pero con nuestros parámetros permitidos
    super
  end

  # --- REENVIO DE INIVITACIÓN ---
  def resend
    user = User.find(params[:id])
    
    if user.invitation_accepted_at.present?
      redirect_to client_path(user.client_id), alert: "El usuario ya aceptó la invitación."
    else
      # Esta línea mágica de Devise reenvía el correo y renueva el token
      user.invite!(current_user) 
      redirect_to client_path(user.client_id), notice: "Invitación reenviada correctamente a #{user.email}."
    end
  end
  # --------------------------

  protected

  # Permitimos los campos extra en el formulario de invitación
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:invite, keys: [:first_name, :last_name, :role, :job_title, :client_id])
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:first_name, :last_name, :phone])
  end

  # Redireccionar al show del cliente después de invitar
  def after_invite_path_for(inviter, invitee)
    if invitee.client_id
      client_path(invitee.client_id)
    else
      root_path
    end
  end
end