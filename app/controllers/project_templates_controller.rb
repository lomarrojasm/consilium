# app/controllers/project_templates_controller.rb
class ProjectTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin! # Asumo que solo los administradores pueden editar metodologías
  before_action :set_project_template, only: %i[ show edit update destroy ]

  def index
    @project_templates = ProjectTemplate.order(created_at: :desc)
  end

  def show
    # Hacemos 'includes' para evitar problemas de N+1 queries al cargar 215 actividades
    @stages = @project_template.stage_templates.includes(:activity_templates).order(:position)
  end

  def new
    @project_template = ProjectTemplate.new
  end

  def create
    # Si el usuario seleccionó una plantilla base para clonar
    if params[:base_template_id].present?
      base_template = ProjectTemplate.find(params[:base_template_id])

      begin
        ProjectTemplate.transaction do
          # 1. Copiamos la base
          @project_template = base_template.dup
          # 2. Sobrescribimos el nombre y descripción con los que el usuario escribió en el modal
          @project_template.name = project_template_params[:name]
          @project_template.description = project_template_params[:description]
          @project_template.save!

          # 3. Clonamos las etapas y sus tareas
          base_template.stage_templates.each do |original_stage|
            new_stage = original_stage.dup
            new_stage.project_template = @project_template
            new_stage.save!

            original_stage.activity_templates.each do |original_activity|
              new_activity = original_activity.dup
              new_activity.stage_template = new_stage
              new_activity.save!
            end
          end
        end
        redirect_to @project_template, notice: "Plantilla '#{@project_template.name}' creada exitosamente a partir de un clon."
      rescue StandardError => e
        redirect_to project_templates_path, alert: "Hubo un error al clonar la metodología: #{e.message}"
      end

    # Si el usuario eligió "Lienzo en blanco"
    else
      @project_template = ProjectTemplate.new(project_template_params)
      if @project_template.save
        redirect_to @project_template, notice: "Plantilla vacía creada exitosamente."
      else
        redirect_to project_templates_path, alert: "Error al crear la plantilla: #{@project_template.errors.full_messages.to_sentence}"
      end
    end
  end

  def edit
  end

  def update
    if @project_template.update(project_template_params)
      redirect_to @project_template, notice: "Plantilla actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project_template = ProjectTemplate.find(params[:id])
    name = @project_template.name
    @project_template.destroy
    redirect_to project_templates_url, notice: "La plantilla '#{name}' ha sido eliminada."
  end

  def clone
    original_template = ProjectTemplate.find(params[:id])

    # Iniciamos una transacción para asegurar que si algo falla, no se copie nada a medias
    ProjectTemplate.transaction do
      @new_template = original_template.dup
      @new_template.name = "#{original_template.name} (Copia)"
      @new_template.save!

      original_template.stage_templates.each do |original_stage|
        new_stage = original_stage.dup
        new_stage.project_template = @new_template
        new_stage.save!

        original_stage.activity_templates.each do |original_activity|
          new_activity = original_activity.dup
          new_activity.stage_template = new_stage
          new_activity.save!
        end
      end
    end

    redirect_to edit_project_template_path(@new_template), notice: "Plantilla clonada con éxito. Modifica el nombre de la nueva copia."
  rescue StandardError => e
    redirect_to project_templates_path, alert: "Hubo un error al clonar: #{e.message}"
  end

  private

  def set_project_template
    @project_template = ProjectTemplate.find(params[:id])
  end

  def project_template_params
    params.require(:project_template).permit(:name, :description, :version)
  end

  def authorize_admin!
    redirect_to root_path, alert: "Acceso denegado." unless current_user.role == "admin"
  end
end
