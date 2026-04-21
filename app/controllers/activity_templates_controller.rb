class ActivityTemplatesController < ApplicationController
  before_action :set_activity_template, only: [ :update, :destroy ]
  before_action :set_stage_template, only: [ :create ]

  # Eliminamos def edit porque ya no hay página de edición, todo es en el modal

  def create
    @activity_template = @stage_template.activity_templates.build(activity_template_params)

    # Buscar el mes y semana más altos de la etapa para proponer el siguiente
    last_activity = @stage_template.activity_templates.order(month: :desc, week: :desc).first
    if last_activity
      @activity_template.month ||= last_activity.month
      @activity_template.week ||= last_activity.week + 1
    else
      @activity_template.month ||= 1
      @activity_template.week ||= 1
    end

    if @activity_template.save
      redirect_to @stage_template.project_template, notice: "Nueva actividad agregada."
    else
      redirect_to @stage_template.project_template, alert: "Error al agregar actividad."
    end
  end

  def update
    if @activity_template.update(activity_template_params)
      redirect_to @activity_template.stage_template.project_template, notice: "Actividad actualizada correctamente."
    else
      # Si hay error, regresamos al template con un alert
      redirect_to @activity_template.stage_template.project_template, alert: "Error al actualizar la actividad."
    end
  end

  def destroy
    project_template = @activity_template.stage_template.project_template
    @activity_template.destroy
    redirect_to project_template, notice: "Actividad eliminada."
  end

  private

  def set_stage_template
    @stage_template = StageTemplate.find(params[:stage_template_id])
  end

  def set_activity_template
    @activity_template = ActivityTemplate.find(params[:id])
  end

  def activity_template_params
    params.require(:activity_template).permit(
      :name, :month, :week, :area, :document_ref,
      :leader_hours, :senior_hours, :analyst_hours,
      :leader_rate, :senior_rate, :analyst_rate
    )
  end
end
