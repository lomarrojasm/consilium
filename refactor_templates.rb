require 'fileutils'

# Lista de archivos a procesar
files = Dir.glob("app/services/project_templates/**/*.rb")

files.each do |path|
  # Saltamos si ya tiene el método
  content = File.read(path)
  next if content.include?("def self.activities_matrix")

  puts "📂 Procesando: #{path}"
  
  # 1. Crear respaldo de seguridad
  FileUtils.cp(path, "#{path}.bak")

  # 2. Reconstruir el contenido
  # Buscamos el inicio de 'actividades = ['
  # y lo dividimos para insertar el método
  
  if content =~ /actividades = \[/
    # Inyectamos el método self.activities_matrix antes de self.generate
    new_content = content.sub(/actividades = \[(.*?)\]/m) do |match|
      # Esto extrae el array y lo pone en un método
      "def self.activities_matrix\n    #{@1.strip}\n  end\n\n  def self.generate(project, user)"
    end

    # Corregimos la llamada al método dentro de generate
    new_content = new_content.gsub(/actividades = \[.*?\]/m, "# actividades movido a método")
    new_content = new_content.gsub("actividades.each_with_index", "self.activities_matrix.each_with_index")
    
    # 3. Guardar el archivo actualizado
    File.write(path, new_content)
    puts "   ✅ Archivo actualizado (respaldo creado como .bak)"
  else
    puts "   ⚠️ No se encontró el bloque 'actividades = [' en este archivo."
  end
end

puts "\n🚀 Proceso finalizado."