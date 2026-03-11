# ==============================================================================
# SEED DE DATOS - CREACIÓN DE ADMINISTRADORES CORE
# ==============================================================================

puts "🏗️ Creando Consultores de Consilium (Admins)..."

# 1. Administrador Principal
User.create!(
  first_name: "Omar", 
  last_name: "Rojas",
  email: "admin@consilium.com", 
  password: "password123",
  password_confirmation: "password123",
  role: 1, 
  active: true, 
  job_title: "Socio Director"
)

# 2. Segundo Administrador
User.create!(
  first_name: "Daniel", 
  last_name: "Burgos",
  email: "admin2@consilium.com", 
  password: "password123",
  password_confirmation: "password123",
  role: 1, 
  active: true, 
  job_title: "Consultor Senior"
)

# 3. Consultor Senior
User.create!(
  first_name: "Victor", 
  last_name: "Pina",
  email: "admin3@consilium.com", 
  password: "password123",
  password_confirmation: "password123",
  role: 1, 
  active: true, 
  job_title: "Socio Director"
)

puts "✅ Se han creado los 3 usuarios administradores con éxito."
puts "-------------------------------------------------------"
puts "ADMIN 1: admin@consilium.com / password123"
puts "ADMIN 2: admin2@consilium.com / password123"
puts "ADMIN 3: beatriz@consilium.com / password123"
puts "-------------------------------------------------------"