# ==============================================================================
# SEED DE DATOS - CONSILIUM PRO (ENTORNO DE PRUEBAS COMPLETO)
# ==============================================================================

puts "🧹 Limpiando base de datos..."
# El orden es vital para no romper llaves foráneas
[TimelineLog, Message, Conversation, ProjectComment, Activity, Stage, ProjectMember, Project, User, Client].each do |model|
  model.delete_all
end

puts "🏗️ Creando Consultores de Consilium (Admins)..."

admin = User.create!(
  first_name: "Omar", last_name: "Rojas",
  email: "admin@consilium.com", password: "password123",
  role: 1, active: true, job_title: "Socio Director"
)

admin2 = User.create!(
  first_name: "Daniel", last_name: "Burgos",
  email: "admin2@consilium.com", password: "password123",
  role: 1, active: true, job_title: "Socio Director"
)

consultor_senior = User.create!(
  first_name: "Beatriz", last_name: "Estratega",
  email: "beatriz@consilium.com", password: "password123",
  role: 1, active: true, job_title: "Consultor Senior"
)

# --- DETECCIÓN AUTOMÁTICA DE STATUS (Para evitar ArgumentError) ---
# Esto toma las llaves que tú tengas definidas en Project.status
STATUS_KEYS = Project.statuses.keys
STATUS_IN_PROGRESS = STATUS_KEYS.include?("in_progress") ? "in_progress" : STATUS_KEYS[1] || STATUS_KEYS[0]
STATUS_WAITING = STATUS_KEYS.include?("waiting") ? "waiting" : STATUS_KEYS[0]

# --- DATOS DE EMPRESAS ---
empresas_data = [
  { name: "Tech Solutions Mexico", rfc: "TSM230101XYZ", ind: "Tecnología", city: "Guadalajara" },
  { name: "Alimentos del Valle", rfc: "ADV880512ABC", ind: "Manufactura", city: "Querétaro" },
  { name: "Constructora Delta", rfc: "CDL950921HJK", ind: "Construcción", city: "Monterrey" },
  { name: "Inmobiliaria Horizonte", rfc: "IHO100203LMN", ind: "Bienes Raíces", city: "CDMX" }
]

puts "🏢 Generando 4 Empresas y sus ecosistemas..."

empresas_data.each_with_index do |data, i|
  # 1. Crear Cliente
  cliente = Client.create!(
    company_name: data[:name],
    trade_name: "#{data[:name]} Comercial",
    rfc: data[:rfc],
    industry: data[:ind],
    country: "México",
    tax_city: data[:city],
    tax_street: "Av. Reforma #{100 + i}",
    operation_year: 5 + (i * 2),
    total_employee: 20 * (i + 1),
    web_page: "www.#{data[:name].parameterize}.com",
    main_issue: "Optimización de procesos operativos en el área de #{data[:ind]}.",
    project_objective: "Implementar la metodología Consilium para escalar la operación."
  )

  # 2. Crear Usuarios de la empresa
  gerente = User.create!(
    first_name: "Gerente", last_name: data[:name].split.first,
    email: "gerente@#{data[:name].parameterize}.com", password: "password123",
    role: 0, client: cliente, active: true, job_title: "Director General"
  )

  staff = User.create!(
    first_name: "Staff", last_name: "Operativo",
    email: "staff@#{data[:name].parameterize}.com", password: "password123",
    role: 0, client: cliente, active: true, job_title: "Coordinador"
  )

  # 3. Proyecto con Metodología Consilium (Solo para la primera empresa)
  if i == 0
    puts "  -> Cargando Metodología Consilium para #{data[:name]}..."
    p_metodologia = Project.create!(
      name: "Transformación Organizacional 2026",
      status: STATUS_IN_PROGRESS,
      start_date: 2.months.ago,
      end_date: 4.months.from_now,
      budget: 250000,
      client: cliente,
      user: admin,
      responsible: gerente,
      details: "Proyecto piloto utilizando las 6 etapas de la metodología Consilium."
    )
    
    # CARGAR ETAPAS REALES DESDE TU SERVICE
    ConsiliumTemplateService.generate_structure(p_metodologia, admin)
    
    # Marcar algunas tareas como completadas para ver progreso
    p_metodologia.stages.first.activities.limit(8).update_all(completed: true, completed_day: 10)
  end

  # 4. Proyecto Estándar para todas las empresas
  puts "  -> Creando proyecto estándar para #{data[:name]}..."
  p_std = Project.create!(
    name: "Auditoría de Procesos #{data[:ind]}",
    status: i.even? ? STATUS_IN_PROGRESS : STATUS_WAITING,
    start_date: 2.weeks.ago,
    end_date: 3.months.from_now,
    budget: 95000,
    client: cliente,
    user: consultor_senior,
    responsible: gerente,
    details: "Análisis profundo de la cadena de valor de #{data[:name]}."
  )

  # Etapa y Actividades manuales
  fase1 = p_std.stages.create!(name: "Levantamiento de Información", position: 1)
  
  fase1.activities.create!(
    name: "Entrevista con responsables de área",
    completed: true,
    user: admin,
    responsible: gerente,
    month: 1, week: 1,
    activity_cost: 2500,
    description: "Sesión inicial para entender el flujo de trabajo."
  )

  fase1.activities.create!(
    name: "Recopilación de manuales existentes",
    completed: false,
    user: gerente,
    responsible: staff,
    month: 1, week: 2,
    document_ref: "REF-PRO-001"
  )

  # 5. Equipo del Proyecto
  ProjectMember.create!(project: p_std, user: staff, role: "analista", added_by: admin)

  # 6. Bitácora y Comunicación
  ProjectComment.create!(
    project: p_std, user: gerente,
    body: "Ya tenemos listos los accesos para el consultor senior.",
    created_at: 3.days.ago
  )

  conv = Conversation.create!(client: cliente, sender: admin, recipient: gerente)
  Message.create!(
    conversation: conv, user: admin, 
    body: "Hola, ¿podrían confirmar la reunión de seguimiento?",
    created_at: 1.day.ago
  )
end

# ==============================================================================
# SINCRONIZACIÓN DE LÍNEA DE TIEMPO (CON SNAPSHOTS)
# ==============================================================================
puts "⏱️ Sincronizando Timeline con Snapshots (Auditoría permanente)..."

# Logs de Proyectos
Project.all.each do |p|
  TimelineLog.create!(
    client: p.client, user: p.user, resource: p,
    resource_name: p.name, # Snapshot para evitar errores si se borra
    action_type: 'create',
    details: "Se inició el proyecto: #{p.name}",
    happened_at: p.created_at
  )
end

# Logs de Actividades
Activity.where(completed: true).each do |a|
  TimelineLog.create!(
    client: a.stage.project.client, user: a.user, resource: a,
    resource_name: a.name, # Snapshot
    action_type: 'update',
    details: "La tarea '#{a.name}' fue marcada como completada.",
    happened_at: a.updated_at
  )
end

# Logs de Comentarios
ProjectComment.all.each do |c|
  TimelineLog.create!(
    client: c.project.client, user: c.user, resource: c,
    resource_name: "Comentario: #{c.project.name}",
    action_type: 'create',
    details: c.body.truncate(60),
    happened_at: c.created_at
  )
end

puts ""
puts "======================================================="
puts "🚀 RESET COMPLETO Y EXITOSO"
puts "======================================================="
puts "  ADMIN:    admin@consilium.com / password123"
puts "  EMPRESA 1 (FULL): gerente@tech-solutions-mexico.com"
puts "  EMPRESA 2: gerente@alimentos-del-valle.com"
puts "  Llaves de Status detectadas: #{STATUS_KEYS.join(', ')}"
puts "======================================================="