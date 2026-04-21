# db/seeds/import_all.rb
require 'parser/current'
require 'unparser'

puts "🚀 Iniciando importación masiva de templates a la BD..."

years = [ 2022, 2023, 2024, 2025, 2026 ]
tiers = [ 'basica', 'gold', 'platinum' ]

stages_definitions = [
  "Etapa 1 - Alinear y Diagnosticar",
  "Etapa 2 - Ordenar y Controlar",
  "Etapa 3 - Estandarizar y Profesionalizar",
  "Etapa 4 - Mejora Continua y Consolidación",
  "Etapa 5 - Optimización y Escalamiento",
  "Etapa 6 - Excelencia Operativa"
]

# Función recursiva que excava hasta el fondo del archivo buscando "actividades = [...]"
def find_actividades_array(node)
  return nil unless node.is_a?(Parser::AST::Node)

  # Si encontramos la asignación local "actividades = [...]"
  if node.type == :lvasgn && node.children[0] == :actividades && node.children[1]&.type == :array
    return node.children[1]
  end

  # Si no, buscamos dentro de sus hijos (módulos, clases, métodos)
  node.children.each do |child|
    found = find_actividades_array(child)
    return found if found
  end

  nil
end

def extract_matrix_from_file(filepath)
  return { status: :not_found, path: filepath } unless File.exist?(filepath)

  code = File.read(filepath)
  ast = Parser::CurrentRuby.parse(code)

  array_node = find_actividades_array(ast)
  return { status: :empty_matrix } unless array_node

  begin
    matrix = eval(Unparser.unparse(array_node))
    { status: :success, data: matrix }
  rescue => e
    { status: :eval_error, message: e.message }
  end
end

# 1. Importar los históricos
years.each do |year|
  tiers.each do |tier|
    # Construye la ruta. (Si tu carpeta tiene mayúsculas, cambia a "Y#{year}")
    filepath = Rails.root.join("app", "services", "project_templates", "y#{year}", "#{tier}_service.rb")

    result = extract_matrix_from_file(filepath)
    template_name = "Generación #{year} - #{tier.capitalize}"

    if result[:status] == :success
      matrix = result[:data]
      template = ProjectTemplate.find_or_create_by!(name: template_name)

      db_stages = {}
      stages_definitions.each_with_index do |name, i|
        db_stages[i + 1] = template.stage_templates.find_or_create_by!(name: name, position: i + 1)
      end

      # Limpiamos las actividades previas por si corres el script varias veces
      template.stage_templates.each { |st| st.activity_templates.destroy_all }

      actividades_count = 0
      matrix.each do |row|
        stage_num = row[0]
        area_principal = row[5].split(',').first.to_s.strip

        db_stages[stage_num].activity_templates.create!(
          month: row[1], week: row[2],
          name: row[3], document_ref: row[4], area: area_principal,
          leader_rate: row[6], senior_rate: row[7], analyst_rate: row[8],
          leader_hours: row[9], senior_hours: row[10], analyst_hours: row[11]
        )
        actividades_count += 1
      end

      puts "✅ #{template_name} importada con #{actividades_count} actividades."
    elsif result[:status] == :not_found
      puts "❌ NO ENCONTRADO: Busqué en #{result[:path]} pero el archivo no existe."
    elsif result[:status] == :empty_matrix
      puts "⚠️ MATRIZ VACÍA: El archivo existe, pero no pude leer el arreglo 'actividades = [...]'. Verifica la sintaxis."
    else
      puts "🔥 ERROR EVALUANDO: #{result[:message]}"
    end
  end
end

puts "🎉 ¡Importación masiva completada!"
