class UsersController < ApplicationController
  before_action :authenticate_user! # Proteger la ruta
  before_action :set_user, only: [:show, :edit, :update]
  before_action :authorize_admin!, only: [:new, :create, :destroy]


  # GET /users/1
  def show
    # @user ya está definido por el before_action set_user
  end

  # GET /users/1/edit
  def edit
    # Rails busca automáticamente la vista en app/views/users/edit.html.erb
  end

  # PATCH/PUT /users/1
  def update
    # Quitamos el password de los params si viene vacío para no sobrescribirlo
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

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_admin!
    unless current_user.role == 'admin'
      # Si la petición es AJAX/Turbo, podemos mostrar un modal o alerta
      respond_to do |format|
        format.html { redirect_to root_path, alert: "No tienes permisos para gestionar usuarios." }
        format.js   { render js: "alert('Acceso denegado');" }
        # Si usas el sistema de modales estáticos que configuramos antes:
        format.turbo_stream { 
          render turbo_stream: turbo_stream.append("body", partial: "shared/modal_access_denied") 
        }
      end
    end
  end

  def user_params
    # Lista blanca de campos permitidos
    params.require(:user).permit(:first_name, :last_name, :email, :job_title, :role, :phone, :active)
  end
end