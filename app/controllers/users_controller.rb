class UsersController < ApplicationController
  before_action :authenticate_user! 
  # Agregamos :destroy y :resend_invitation al set_user
  before_action :set_user, only: [:show, :edit, :update, :destroy, :resend_invitation]
  # Protegemos todas estas acciones para que solo el admin pueda ejecutarlas
  before_action :authorize_admin!, only: [:show, :edit, :update, :destroy, :resend_invitation]

  # GET /users/1
  def show
  end

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1
  def update
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update(user_params)
      # Redireccionamos al cliente al que pertenece el usuario
      redirect_to client_path(@user.client_id), notice: 'Usuario actualizado correctamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # POST /users/1/resend_invitation
  def resend_invitation
    @user.invite! 
    redirect_back fallback_location: users_path, notice: "Invitación reenviada con éxito a #{@user.email}"
  end

  # DELETE /users/1
  def destroy
    client_id = @user.client_id
    @user.destroy
    # Redireccionamos al cliente para que el admin vea la lista actualizada
    redirect_to client_path(client_id), notice: 'Usuario eliminado definitivamente.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_admin!
    unless current_user.role == 'admin'
      respond_to do |format|
        format.html { redirect_to root_path, alert: "No tienes permisos para realizar esta acción." }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.append("body", partial: "shared/modal_access_denied") 
        }
      end
    end
  end

  def user_params
    # Asegúrate de incluir :avatar si permites que el admin cambie la foto desde aquí
    params.require(:user).permit(:first_name, :last_name, :email, :job_title, :role, :phone, :active, :avatar)
  end
end