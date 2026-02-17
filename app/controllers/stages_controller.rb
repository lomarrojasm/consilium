class StagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_context

  #Autorozacoión de usuarios
  before_action :authorize_project_member!
  
  before_action :set_stage, only: [:edit, :update, :destroy]

  

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
    if @stage.update(stage_params)
      redirect_to client_project_path(@client, @project), notice: 'Etapa actualizada.'
    else
      render :edit
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

  def stage_params
    params.require(:stage).permit(:name, :position)
  end
end