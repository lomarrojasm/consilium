# app/controllers/stage_templates_controller.rb
class StageTemplatesController < ApplicationController
  before_action :set_project_template, only: [ :create ]
  before_action :set_stage_template, only: [ :destroy ]

  def create
    @stage = @project_template.stage_templates.build(stage_template_params)

    # Asignar la siguiente posición automáticamente
    last_position = @project_template.stage_templates.maximum(:position) || 0
    @stage.position = last_position + 1

    if @stage.save
      redirect_to @project_template, notice: "Nueva etapa agregada correctamente."
    else
      redirect_to @project_template, alert: "Error al crear la etapa."
    end
  end

  def destroy
    # Quitamos el .stage_template intermedio porque la etapa ya pertenece al proyecto directo
    project_template = @stage.project_template

    @stage.destroy
    redirect_to project_template, notice: "Etapa eliminada correctamente."
  end

  private

  def set_project_template
    @project_template = ProjectTemplate.find(params[:project_template_id])
  end

  def set_stage_template
    @stage = StageTemplate.find(params[:id])
  end

  def stage_template_params
    params.require(:stage_template).permit(:name)
  end
end
