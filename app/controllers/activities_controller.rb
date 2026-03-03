class ActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_context

  #Autorozacoión de usuarios
  # Todos pueden ver el proyecto, pero solo el Líder/Senior puede crear/editar actividades
  before_action :authorize_project_member!, only: [:index, :show]
  before_action :authorize_lider_or_senior!, only: [:new, :create, :edit, :update, :destroy]

  def new
  @activity = @project.activities.build
  
  # Si en la URL viene ?stage_id=5, preseleccionamos esa etapa
  if params[:stage_id].present?
    @activity.stage_id = params[:stage_id]
  else
    # Si no, por defecto la primera etapa activa o la primera disponible
    @activity.stage_id = @project.stages.first&.id
  end
end

  def create
  # Buscamos la etapa seleccionada en el formulario
  stage = Stage.find(activity_params[:stage_id])
  @activity = stage.activities.build(activity_params)

  @activity.user = current_user
  
  if @activity.save
    redirect_to client_project_path(@client, @project), notice: 'Actividad creada manualmente.'
  else
    # Si falla, volvemos a renderizar el formulario
    render :new, status: :unprocessable_entity
  end
end

  def edit
    # @activity ya está seteada por el before_action
  end

  def update
    if @activity.update(activity_params)
      # Calculamos el costo total de la actividad sumando los sub-costos
      total_cost = (@activity.leader_cost || 0) + (@activity.senior_cost || 0) + (@activity.analyst_cost || 0)
      @activity.update_column(:activity_cost, total_cost)

      redirect_to client_project_path(@client, @project), notice: 'Actividad actualizada correctamente.'
    else
      render :edit
    end
  end

  def destroy
    @activity.destroy
    redirect_to client_project_path(@client, @project), notice: 'Actividad eliminada.'
  end


  def toggle
    # @activity ya viene del before_action
    @activity.update(completed: !@activity.completed)
    
    respond_to do |format|
      # HTML normal: Redirige (para navegadores viejos)
      format.html { redirect_to client_project_path(@client, @project), notice: "Estatus actualizado." }
      
      # Turbo: Responde "OK" (Status 200) sin contenido. 
      # Esto guarda el dato pero deja la página quieta.
      format.turbo_stream { head :ok }
    end
  end

  def upload_evidence
    @activity = Activity.find(params[:id])
    
    # 1. Adjuntar el archivo
    if params[:activity] && params[:activity][:evidence].present?
      @activity.evidence.attach(params[:activity][:evidence])
    end

    # 2. Marcar como completada y asignar usuario
    @activity.completed = true
    @activity.user = current_user

    # NUEVO: Guardamos el día actual (1-31) en completed_day
    @activity.completed_day = Time.current.day

    if @activity.save
      redirect_to client_project_path(@client, @project), notice: "Evidencia cargada y actividad finalizada."
    else
      redirect_to client_project_path(@client, @project), alert: "Error: #{@activity.errors.full_messages.join(', ')}"
    end
  end

  private

  def set_context
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:project_id])
    @activity = Activity.find(params[:id]) if params[:id]
  end

  def activity_params
    params.require(:activity).permit(
      :name, :document_ref, :stage_id, :month, :week, :completed_day, :area, :completed,
      :leader_hours, :leader_rate, :leader_cost,
      :senior_hours, :senior_rate, :senior_cost,
      :analyst_hours, :analyst_rate, :analyst_cost,
      :activity_cost,
      :responsible_id
    )
  end
end