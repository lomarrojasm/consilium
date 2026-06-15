# app/services/template_rebuilder_service.rb
class TemplateRebuilderService
  def self.call(user)
    # 1. Limpiamos la base de datos de plantillas
    ProjectTemplate.destroy_all
    StageTemplate.destroy_all
    ActivityTemplate.destroy_all

    # 2. Definición de la estructura de etapas por año
    stages_by_year = {
      2022 => [ "Etapa 1 - Alinear y Diagnosticar", "Etapa 2 - Ordenar y Controlar", "Etapa 3 - Estandarizar y Profesionalizar", "Etapa 4 - Mejora Continua y Consolidación", "Etapa 5 - Optimización y Escalamiento", "Etapa 6 - Excelencia Operativa" ],
      2023 => [ "Etapa 1 - Alinear y Diagnosticar", "Etapa 2 - Ordenar y Controlar", "Etapa 3 - Estandarizar y Profesionalizar", "Etapa 4 - Mejora Continua y Consolidación", "Etapa 5 - Optimización y Escalamiento" ],
      2024 => [ "Etapa 1 - Alinear y Diagnosticar", "Etapa 2 - Ordenar y Controlar", "Etapa 3 - Estandarizar y Profesionalizar", "Etapa 4 - Mejora Continua y Consolidación" ],
      2025 => [ "Etapa 1 - Alinear y Diagnosticar", "Etapa 2 - Ordenar y Controlar", "Etapa 3 - Estandarizar y Profesionalizar" ],
      2026 => [ "Etapa 1 - Alinear y Diagnosticar", "Etapa 2 - Ordenar y Controlar" ],
      nil  => [ "Etapa 1 - Alinear y Diagnosticar", "Etapa 2 - Ordenar y Controlar", "Etapa 3 - Estandarizar y Profesionalizar", "Etapa 4 - Mejora Continua y Consolidación", "Etapa 5 - Optimización y Escalamiento", "Etapa 6 - Excelencia Operativa" ]
    }

    # 3. Ejecución masiva
    [ nil, 2022, 2023, 2024, 2025, 2026 ].each do |year|
      [ "Basica", "Gold", "Platinum" ].each do |membership|
        template_name = year ? "Plantilla #{membership} #{year}" : "Plantilla #{membership} Base"

        begin
          service_class = if year.nil?
                            "Template#{membership}Service".constantize
          else
                            "ProjectTemplates::Y#{year}::#{membership}Service".constantize
          end
        rescue NameError
          next
        end

        pt = ProjectTemplate.create!(name: template_name)
        stages_hash = {}

        stages_by_year[year].each_with_index do |stage_name, i|
          stages_hash[i + 1] = pt.stage_templates.create!(position: i + 1, name: stage_name)
        end

        # Inyectar Actividades asegurando la posición y la fecha estática
        service_class.activities_matrix.each_with_index do |row, index|
          stage_num = row[0]
          target_stage = stages_hash[stage_num]

          if target_stage
            fecha_fija = row[12]

            actividad = target_stage.activity_templates.create!(
              activity_number: row[2],
              name: row[3],
              month: row[1],
              week: row[2],
              document_ref: row[4],
              area: row[5].to_s.split(",").first.to_s.strip,
              activity_cost: (row[6].to_f * row[9].to_f) + (row[7].to_f * row[10].to_f) + (row[8].to_f * row[11].to_f),
              leader_rate: row[6].to_f, senior_rate: row[7].to_f, analyst_rate: row[8].to_f,
              leader_hours: row[9].to_f, senior_hours: row[10].to_f, analyst_hours: row[11].to_f,
              user_id: user.id, responsible_id: user.id, status: "pending", completed: false,
              position: index
            )

            # Forzar inyección de fecha exacta
            if fecha_fija.present?
              fecha_parseada = Time.zone.parse(fecha_fija.to_s) rescue fecha_fija
              actividad.update_columns(created_at: fecha_parseada, updated_at: fecha_parseada)
            end
          end
        end
      end
    end
  end
end
