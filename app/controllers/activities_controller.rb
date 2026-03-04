class ActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_context

  # --- SEGURIDAD ---
  # Quitamos :index y :show porque no existen en este controlador.
  # 'edit' se permite a miembros para que puedan ver el timeline/modal.
  before_action :authorize_project_member!, only: [:edit]
  # Acciones que modifican o crean datos quedan para Líder/Senior o Admin.
  before_action :authorize_lider_or_senior!, only: [:new, :create, :update, :destroy, :update_status, :toggle, :upload_evidence]

  def new
    @activity = @project.activities.build
    
    # Preselección de etapa desde parámetros
    if params[:stage_id].present?
      @activity.stage_id = params[:stage_id]
    else
      @activity.stage_id = @project.stages.first&.id
    end
  end

  def create
    stage = @project.stages.find(activity_params[:stage_id])
    @activity = stage.activities.build(activity_params)
    @activity.user = current_user
    
    if @activity.save
      redirect_to client_project_path(@client, @project), notice: 'Actividad creada con éxito.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @activity = @project.activities.find(params[:id])
    # Aquí NO usamos render partial, dejamos que Rails busque edit.html.erb
  end

  def tracking
    @activity = @project.activities.find(params[:id])
    render partial: 'activities/activity_modal', locals: { activity: @activity }, layout: false
  end

  def update
    if @activity.update(activity_params)
      # Mantenemos tu funcionalidad de cálculo de costos
      total_cost = (@activity.leader_cost || 0) + (@activity.senior_cost || 0) + (@activity.analyst_cost || 0)
      @activity.update_column(:activity_cost, total_cost)

      redirect_to client_project_path(@client, @project), notice: 'Actividad actualizada correctamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @activity.destroy
    redirect_to client_project_path(@client, @project), notice: 'Actividad eliminada.'
  end

  def toggle
    @activity.update(completed: !@activity.completed)
    
    respond_to do |format|
      format.html { redirect_to client_project_path(@client, @project), notice: "Estatus actualizado." }
      format.turbo_stream { head :ok }
    end
  end

  def upload_evidence
    # Manejo de carga de evidencia y finalización de tarea
    if params[:activity] && params[:activity][:evidence].present?
      @activity.evidence.attach(params[:activity][:evidence])
      @activity.update(
        completed: true, 
        user: current_user, 
        completed_day: Time.current.day
      )
      redirect_to client_project_path(@client, @project), notice: "Evidencia cargada y actividad finalizada."
    else
      redirect_to client_project_path(@client, @project), alert: "Debes adjuntar un archivo."
    end
  end

  # --- NUEVA FUNCIONALIDAD: APROBACIÓN Y TIMELINE ---
  def update_status
  @activity = @project.activities.find(params[:id])
  new_status = params[:status]
  comment = params[:comment]

  # 1. Actualizamos el estado de la actividad principal
  if @activity.update(status: new_status, completed: (new_status == 'approved'))
    
    # 2. Creamos el registro en el Timeline
    log = @activity.activity_logs.create!(
      user: current_user,
      status: new_status,
      comment: comment
    )
    
    # 3. GUARDADO DE ARCHIVOS: Es vital que el nombre coincida con el del formulario
    if params[:attachments].present?
      log.attachments.attach(params[:attachments])
    end

    redirect_to client_project_path(@client, @project), notice: "Seguimiento guardado correctamente."
  else
    redirect_to client_project_path(@client, @project), alert: "Error al guardar el seguimiento."
  end
end

  private

  def set_context
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:project_id])
    # Simplificamos la búsqueda de la actividad
    @activity = @project.activities.find(params[:id]) if params[:id]
  end

  # Autorizaciones (Asegúrate de tener estos métodos definidos o heredados)
  def authorize_project_member!
    # Lógica para permitir ver (Analistas, Consultores, etc.)
  end

  def authorize_lider_or_senior!
    # Lógica restrictiva para cambios críticos
  end

  def activity_params
    params.require(:activity).permit(
      :name, :description, :document_ref, :stage_id, :month, :week, :completed_day, :area, :completed, :status,
      :leader_hours, :leader_rate, :leader_cost,
      :senior_hours, :senior_rate, :senior_cost,
      :analyst_hours, :analyst_rate, :analyst_cost,
      :activity_cost, :responsible_id
    )
  end
end