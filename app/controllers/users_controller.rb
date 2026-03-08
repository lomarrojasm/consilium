class UsersController < ApplicationController
  before_action :authenticate_user! 
  before_action :set_user, only: [:show, :edit, :update, :destroy, :resend_invitation, :impersonate]
  
  # Usamos el filtro global definido en ApplicationController
  before_action :authorize_admin!, except: [:stop_impersonating]

  def index
    @users = User.includes(:client).all.order(created_at: :desc)
  end

  def show; end
  def edit; end

  def update
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update(user_params)
      redirect_to users_path, notice: 'Usuario actualizado correctamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def resend_invitation
    @user.invite! 
    redirect_back fallback_location: users_path, notice: "Invitación reenviada con éxito a #{@user.email}"
  end

  def destroy
    client_id = @user.client_id
    @user.destroy
    redirect_to client_path(client_id), notice: 'Usuario eliminado definitivamente.'
  end

  # =========================================================================
  # IMPERSONACIÓN (Pretender)
  # =========================================================================

  def impersonate
    if @user == true_user
      redirect_to users_path, alert: "No puedes personificarte a ti mismo."
    else
      impersonate_user(@user)
      # Al impersonar, mandamos directo al portal del cliente para evitar bucles en el dashboard admin
      redirect_to client_dashboard_path, notice: "Modo soporte activo: #{@user.first_name}"
    end
  end

  def stop_impersonating
    stop_impersonating_user
    redirect_to users_path, notice: "Has vuelto a tu cuenta administrativa."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :job_title, :role, :phone, :active, :avatar)
  end
end