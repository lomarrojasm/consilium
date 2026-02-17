# ==============================================================================
# SEED DE DATOS - CONSILIUM
# Genera un entorno de pruebas completo con historial cronológico.
# ==============================================================================

puts "🧹 Limpiando base de datos..."

# El orden es IMPORTANTE para evitar errores de llave foránea (Foreign Keys)
TimelineLog.delete_all
Message.delete_all
Conversation.delete_all
ProjectComment.delete_all # <--- AGREGADO: Limpiar comentarios
Activity.delete_all
Stage.delete_all
ProjectMember.delete_all
Project.delete_all
User.delete_all
Client.delete_all

puts "🏗 Creando estructura base..."

# 1. Crear el Cliente
empresa = Client.create!(
  company_name: "Tech Solutions Mexico S.A. de C.V.",
  rfc: "TSM230101XYZ",
  industry: "Tecnología",
  country: "México",
  tax_city: "Guadalajara"
)

# 2. Crear Usuarios
# Admin (El consultor principal)
admin = User.create!(
  first_name: "Carlos",
  last_name: "Consultor",
  email: "admin@consilium.com",
  password: "password123",
  password_confirmation: "password123",
  role: 1, # Admin
  active: true,
  job_title: "Socio Director"
)

# Usuario Cliente (El contacto principal)
cliente_admin = User.create!(
  first_name: "Luis",
  last_name: "Mercado",
  email: "user@cliente.com",
  password: "password123",
  password_confirmation: "password123",
  role: 0, # User
  client: empresa,
  active: true,
  job_title: "Gerente General"
)

# Otro Usuario Cliente (Para probar asignaciones de equipo)
cliente_staff = User.create!(
  first_name: "Ana",
  last_name: "López",
  email: "ana@cliente.com",
  password: "password123",
  password_confirmation: "password123",
  role: 0,
  client: empresa,
  active: true,
  job_title: "Contadora"
)

puts "📚 Generando Historia (Proyectos y Actividades)..."

# --- PROYECTO 1: Hace 2 meses (Ya avanzado) ---
fecha_inicio_p1 = 2.months.ago

p1 = Project.create!(
  name: "Implementación ISO 9001",
  status: 1,
  start_date: fecha_inicio_p1,
  end_date: 1.month.from_now,
  budget: 120000.00,
  client: empresa,
  user: admin, # Creado por admin
  created_at: fecha_inicio_p1,
  updated_at: fecha_inicio_p1
)

# Comentario en Proyecto 1 (Hace 1 mes)
ProjectComment.create!(
  project: p1,
  user: cliente_admin,
  body: "Adjunto la revisión preliminar del manual de calidad para su visto bueno.",
  created_at: 1.month.ago,
  updated_at: 1.month.ago
)

# Etapas P1
s1 = p1.stages.create!(name: "Diagnóstico Inicial", position: 1, status: 1)
s2 = p1.stages.create!(name: "Documentación", position: 2, status: 1)

# Actividades P1
Activity.create!(
  name: "Revisión de procesos actuales",
  completed: true,
  stage: s1,
  user: cliente_admin,
  description: "Se levantó el mapa de procesos del área de ventas.",
  created_at: fecha_inicio_p1 + 2.days,
  updated_at: fecha_inicio_p1 + 5.days
)

Activity.create!(
  name: "Capacitación al personal",
  completed: true,
  stage: s1,
  user: cliente_staff,
  description: "Sesión de 4 horas con el equipo operativo.",
  created_at: fecha_inicio_p1 + 1.week,
  updated_at: fecha_inicio_p1 + 1.week
)

# Asignar miembro al equipo
pm1 = ProjectMember.create!(
  project: p1,
  user: cliente_staff,
  added_by: admin,
  created_at: 1.month.ago,
  updated_at: 1.month.ago
)

# --- PROYECTO 2: Hace 1 semana (Reciente) ---
fecha_inicio_p2 = 1.week.ago

p2 = Project.create!(
  name: "Auditoría Fiscal 2026",
  status: 1,
  start_date: fecha_inicio_p2,
  end_date: 2.months.from_now,
  budget: 50000.00,
  client: empresa,
  user: admin,
  created_at: fecha_inicio_p2,
  updated_at: fecha_inicio_p2
)

# Comentario en Proyecto 2 (Hoy)
ProjectComment.create!(
  project: p2,
  user: admin,
  body: "URGENTE: Necesitamos los estados de cuenta bancarios antes del viernes.",
  created_at: 2.hours.ago,
  updated_at: 2.hours.ago
)

s_p2 = p2.stages.create!(name: "Requerimientos", position: 1)

Activity.create!(
  name: "Entrega de Balanza de Comprobación",
  completed: true,
  stage: s_p2,
  user: cliente_admin,
  created_at: 3.days.ago,
  updated_at: 2.days.ago
)

puts "💬 Generando Chats..."

conv = Conversation.create!(
  client: empresa,
  sender: admin,
  recipient: cliente_admin
)

Message.create!(
  conversation: conv,
  user: admin,
  body: "Hola Luis, bienvenidos a la plataforma Consilium.",
  messaged_at: 2.months.ago,
  created_at: 2.months.ago
)

Message.create!(
  conversation: conv,
  user: cliente_admin,
  body: "Gracias Carlos, ya subimos la información del primer proyecto.",
  messaged_at: 1.month.ago,
  created_at: 1.month.ago
)

Message.create!(
  conversation: conv,
  user: admin,
  body: "Perfecto, revisaré la auditoría esta semana.",
  messaged_at: 1.hour.ago,
  created_at: 1.hour.ago
)

# ==============================================================================
# GENERACIÓN FORZADA DE TIMELINE LOGS (BACKFILL)
# ==============================================================================
puts "⏱ Sincronizando Timeline Logs con fechas históricas..."

TimelineLog.delete_all # Borramos logs automáticos para regenerarlos con fechas correctas

# 1. Logs de Proyectos
Project.all.each do |p|
  TimelineLog.create!(
    client: p.client,
    user: p.user,
    resource: p,
    action_type: 'create',
    details: "Creó el proyecto: #{p.name}",
    happened_at: p.created_at
  )
end

# 2. Logs de Actividades
Activity.where(completed: true).each do |a|
  TimelineLog.create!(
    client: a.stage.project.client,
    user: a.user,
    resource: a,
    action_type: 'update',
    details: "Completó la actividad: #{a.name}",
    happened_at: a.updated_at
  )
end

# 3. Logs de Mensajes
Message.all.each do |m|
  TimelineLog.create!(
    client: m.conversation.client,
    user: m.user,
    resource: m,
    action_type: 'create',
    details: "Mensaje: #{m.body.truncate(30)}",
    happened_at: m.created_at
  )
end

# 4. Logs de Comentarios de Proyecto (NUEVO)
ProjectComment.all.each do |c|
  TimelineLog.create!(
    client: c.project.client,
    user: c.user,
    resource: c,
    action_type: 'create',
    details: "Comentó en #{c.project.name}: #{c.body.truncate(30)}",
    happened_at: c.created_at
  )
end

# 5. Logs de Miembros
ProjectMember.all.each do |pm|
  TimelineLog.create!(
    client: pm.project.client,
    user: pm.added_by,
    resource: pm,
    action_type: 'create',
    details: "Agregó a #{pm.user.first_name} al equipo",
    happened_at: pm.created_at
  )
end

puts "-------------------------------------------------------"
puts "✅ DB RESET COMPLETADO CON COMENTARIOS"
puts "-------------------------------------------------------"
puts "Admin: admin@consilium.com / password123"
puts "User:  user@cliente.com / password123"
puts "-------------------------------------------------------"