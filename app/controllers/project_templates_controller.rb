class ProjectTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin! # Asumo que solo los administradores pueden editar metodologías
  before_action :set_project_template, only: %i[ show edit update destroy ]

  def index
    @project_templates = ProjectTemplate.order(created_at: :desc)
  end

  def rebuild_all
    begin
      # Ejecutamos el servicio pasándole el usuario actual
      TemplateRebuilderService.call(current_user)

      redirect_to project_templates_path, notice: "✅ ¡Todas las plantillas han sido reconstruidas y actualizadas con éxito!"
    rescue StandardError => e
      redirect_to project_templates_path, alert: "❌ Hubo un error al reconstruir las plantillas: #{e.message}"
    end
  end

  def show
    # Hacemos 'includes' para evitar problemas de N+1 queries al cargar 215 actividades
    @stages = @project_template.stage_templates.includes(:activity_templates).order(:position)
  end

  def new
    @project_template = ProjectTemplate.new
  end

  def create
    # 1. IMPORTAR DESDE EXCEL
    if params[:excel_file].present?
      begin
        ProjectTemplate.transaction do
          # Creamos la plantilla base
          @project_template = ProjectTemplate.create!(
            name: params[:project_template][:name],
            description: params[:project_template][:description]
          )

          stages_definitions = [
            "Etapa 1 - Alinear y Diagnosticar",
            "Etapa 2 - Ordenar y Controlar",
            "Etapa 3 - Estandarizar y Profesionalizar",
            "Etapa 4 - Mejora Continua y Consolidación",
            "Etapa 5 - Optimización y Escalamiento",
            "Etapa 6 - Excelencia Operativa",
            "Etapa 7 - Expansión Estratégica e Innovación",
            "Etapa 8 - Institucionalización y Permanencia"
          ]

          stages_hash = {}
          stages_definitions.each_with_index do |name, i|
            stages_hash[i + 1] = @project_template.stage_templates.find_or_create_by!(position: i + 1, name: name)
          end

          file = params[:excel_file]
          spreadsheet = Roo::Spreadsheet.open(file.tempfile.path, extension: :xlsx)
          sheet = spreadsheet.sheet(0)

          (2..sheet.last_row).each_with_index do |row_num, index|
            row = sheet.row(row_num)

            stage_num = row[0].to_i
            mes       = row[1].to_i
            semana    = row[2].to_i
            nombre    = row[3].to_s.strip
            doc_ref   = row[4].to_s.strip
            areas_raw = row[5].to_s.strip
            area_principal = areas_raw.split(",").first.to_s.strip

            tar_l = row[6].to_f
            tar_s = row[7].to_f
            tar_a = row[8].to_f
            hrs_l = row[9].to_f
            hrs_s = row[10].to_f
            hrs_a = row[11].to_f

            # Recuperamos la fecha de la columna M
            fecha_fija = row[12]

            costo_calc = (tar_l * hrs_l) + (tar_s * hrs_s) + (tar_a * hrs_a)

            target_stage = stages_hash[stage_num]

            if target_stage
              # Guardamos en variable para poder actualizarla después
              actividad = target_stage.activity_templates.create!(
                activity_number: semana,
                name: nombre,
                month: mes,
                week: semana,
                document_ref: doc_ref,
                area: area_principal,
                activity_cost: costo_calc,
                leader_rate: tar_l,
                senior_rate: tar_s,
                analyst_rate: tar_a,
                leader_hours: hrs_l,
                senior_hours: hrs_s,
                analyst_hours: hrs_a,
                position: index
              )

              # --- FIX: Inyección de Fecha Forzada ---
              if fecha_fija.present?
                # Parseamos la fecha por seguridad para que la base de datos la acepte perfecto
                fecha_parseada = Time.zone.parse(fecha_fija.to_s) rescue fecha_fija
                actividad.update_columns(created_at: fecha_parseada, updated_at: fecha_parseada)
              end
            end
          end
        end
        redirect_to @project_template, notice: "Plantilla creada e importada desde Excel exitosamente."
      rescue StandardError => e
        # ESTO FORZARÁ EL ERROR ROJO EN EL NAVEGADOR Y LA TERMINAL SI ALGO FALLA
        puts "🔴" * 20
        puts "ERROR AL IMPORTAR FILA DE EXCEL:"
        puts e.message
        puts "🔴" * 20
        raise e
      end

    # 2. CLONAR DESDE PLANTILLA BASE EXISTENTE
    elsif params[:base_template_id].present?
      base_template = ProjectTemplate.find(params[:base_template_id])
      begin
        ProjectTemplate.transaction do
          @project_template = base_template.dup
          @project_template.name = params[:project_template][:name]
          @project_template.description = params[:project_template][:description]
          @project_template.save!

          base_template.stage_templates.each do |original_stage|
            new_stage = original_stage.dup
            new_stage.project_template = @project_template
            new_stage.save!

            original_stage.activity_templates.each do |original_activity|
              new_activity = original_activity.dup
              new_activity.stage_template = new_stage
              new_activity.save!

              # Conservar fechas al clonar
              new_activity.update_columns(
                created_at: original_activity.created_at,
                updated_at: original_activity.updated_at
              )
            end
          end
        end
        redirect_to @project_template, notice: "Plantilla '#{@project_template.name}' creada exitosamente a partir de un clon."
      rescue StandardError => e
         redirect_to project_templates_path, alert: "Hubo un error al clonar: #{e.message}"
      end

    # 3. LIENZO EN BLANCO
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

          # --- EL PARCHE PARA CONSERVAR LAS FECHAS ---
          # Forzamos las fechas originales saltándonos los callbacks de Rails
          new_activity.update_columns(
            created_at: original_activity.created_at,
            updated_at: original_activity.updated_at
          )
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
