class StagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_context

  #Autorozacoión de usuarios
  before_action :authorize_project_member!
  
  before_action :set_stage, only: [:edit, :update, :destroy]
  before_action :check_stage_lock!, only: [:edit, :update, :destroy]

  

  def new
    @stage = @project.stages.build
  end

  def create
    @stage = @project.stages.build(stage_params)
    # Asignamos la última posición + 1 automáticamente
    @stage.position = (@project.stages.maximum(:position) || 0) + 1
    
    if @stage.save
      redirect_to client_project_path(@client, @project), notice: 'Nueva etapa creada.'
    else
      render :new
    end
  end

  def edit
  end

  def update

    # Seguridad: Solo admin puede modificar la fecha de creación
    unless current_user.role == 'admin'
      params[:stage].delete(:created_at)
    end


    if @stage.update(stage_params)
      redirect_to client_project_path(@client, @project), notice: 'Etapa actualizada.'
    else
      redirect_to client_project_path(@client, @project), alert: 'No se pudo actualizar la etapa.'
    end
  end

  def destroy
    @stage.destroy
    redirect_to client_project_path(@client, @project), notice: 'Etapa eliminada correctamente.'
  end

  private

  def set_context
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:project_id])
  end

  def set_stage
    @stage = @project.stages.find(params[:id])
  end

  def check_stage_lock!
    # Usamos current_user para que el impersonate te bloquee el acceso
    if @stage.locked_for?(current_user)
      redirect_to client_project_path(@client, @project), 
                  alert: "Esta etapa está finalizada y bloqueada para cambios."
    end
  end

  def stage_params
    params.require(:stage).permit(:name, :position, :created_at)
  end
end