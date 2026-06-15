# 1. Definición de la estructura de etapas por año
stages_by_year = {
  2022 => [ "Etapa 1 - Alinear y Diagnosticar", "Etapa 2 - Ordenar y Controlar", "Etapa 3 - Estandarizar y Profesionalizar", "Etapa 4 - Mejora Continua y Consolidación", "Etapa 5 - Optimización y Escalamiento", "Etapa 6 - Excelencia Operativa" ],
  2023 => [ "Etapa 1 - Alinear y Diagnosticar", "Etapa 2 - Ordenar y Controlar", "Etapa 3 - Estandarizar y Profesionalizar", "Etapa 4 - Mejora Continua y Consolidación", "Etapa 5 - Optimización y Escalamiento" ],
  2024 => [ "Etapa 1 - Alinear y Diagnosticar", "Etapa 2 - Ordenar y Controlar", "Etapa 3 - Estandarizar y Profesionalizar", "Etapa 4 - Mejora Continua y Consolidación" ],
  2025 => [ "Etapa 1 - Alinear y Diagnosticar", "Etapa 2 - Ordenar y Controlar", "Etapa 3 - Estandarizar y Profesionalizar" ],
  2026 => [ "Etapa 1 - Alinear y Diagnosticar", "Etapa 2 - Ordenar y Controlar" ],
  nil  => [ "Etapa 1 - Alinear y Diagnosticar", "Etapa 2 - Ordenar y Controlar", "Etapa 3 - Estandarizar y Profesionalizar", "Etapa 4 - Mejora Continua y Consolidación", "Etapa 5 - Optimización y Escalamiento", "Etapa 6 - Excelencia Operativa" ]
}

# Obtenemos el usuario para la asignación
user = User.first

# 2. Ejecución masiva
[ nil, 2022, 2023, 2024, 2025, 2026 ].each do |year|
  [ "Basica", "Gold", "Platinum" ].each do |membership|
    template_name = year ? "Plantilla #{membership} #{year}" : "Plantilla #{membership} Base"
    puts "\n🛠 Construyendo: #{template_name}..."

    # Buscar la clase dinámica
    begin
      service_class = if year.nil?
                        "Template#{membership}Service".constantize
      else
                        "ProjectTemplates::Y#{year}::#{membership}Service".constantize
      end
    rescue NameError
      next
    end

    # Crear/Limpiar Template
    pt = ProjectTemplate.find_or_create_by!(name: template_name)
    pt.stage_templates.destroy_all

    # Crear Etapas
    stages_hash = {}
    stages_by_year[year].each_with_index do |stage_name, i|
      stages_hash[i + 1] = pt.stage_templates.create!(position: i + 1, name: stage_name)
    end

    # 3. Inyectar Actividades con TODOS los campos
    service_class.activities_matrix.each_with_index do |row, index|
      stage_num = row[0]
      target_stage = stages_hash[stage_num]

      if target_stage
        # Preparación de variables de cálculo
        tar_l = row[6].to_f; tar_s = row[7].to_f; tar_a = row[8].to_f
        hrs_l = row[9].to_f; hrs_s = row[10].to_f; hrs_a = row[11].to_f
        costo_calc = (tar_l * hrs_l) + (tar_s * hrs_s) + (tar_a * hrs_a)
        fecha_fija = row[12]

        target_stage.activity_templates.create!(
          activity_number: row[2],
          name: row[3],
          month: row[1],
          week: row[2],
          document_ref: row[4],
          area: row[5].to_s.split(",").first.to_s.strip,
          activity_cost: costo_calc,
          leader_rate: tar_l,
          senior_rate: tar_s,
          analyst_rate: tar_a,
          leader_hours: hrs_l,
          senior_hours: hrs_s,
          analyst_hours: hrs_a,
          user_id: user.id,
          responsible_id: user.id,
          status: "pending",
          completed: false,
          created_at: fecha_fija,
          updated_at: fecha_fija,
          position: index
        )
      end
    end
  end
end
puts "\n✅ ¡Reconstrucción finalizada con éxito!"
