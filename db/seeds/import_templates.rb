# Creamos el primer template oficial
template = ProjectTemplate.find_or_create_by!(name: "Metodología Consilium - Básica")

stages_definitions = [
  "Etapa 1 - Alinear y Diagnosticar",
  "Etapa 2 - Ordenar y Controlar",
  "Etapa 3 - Estandarizar y Profesionalizar",
  "Etapa 4 - Mejora Continua y Consolidación",
  "Etapa 5 - Optimización y Escalamiento",
  "Etapa 6 - Excelencia Operativa"
]

# Crear Etapas
db_stages = {}
stages_definitions.each_with_index do |name, i|
  db_stages[i + 1] = template.stage_templates.find_or_create_by!(
    name: name,
    position: i + 1
  )
end

# Importar Actividades desde tu matriz actual
TemplateBasicaService.activities_matrix.each do |row|
  stage_num = row[0]
  areas_raw = row[5]
  area_principal = areas_raw.split(',').first.to_s.strip

  db_stages[stage_num].activity_templates.create!(
    month: row[1],
    week: row[2],
    name: row[3],
    document_ref: row[4],
    area: area_principal,
    leader_rate: row[6], senior_rate: row[7], analyst_rate: row[8],
    leader_hours: row[9], senior_hours: row[10], analyst_hours: row[11]
  )
end
