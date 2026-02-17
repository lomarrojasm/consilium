class ConsiliumTemplateService
  def self.generate_structure(project, user)
    stages_definitions = [
      { number: 1, name: "Etapa 1 - Alinear y Diagnosticar" },
      { number: 2, name: "Etapa 2 - Ordenar y Controlar" },
      { number: 3, name: "Etapa 3 - Estandarizar y Profesionalizar" },
      { number: 4, name: "Etapa 4 - Mejora Continua y Consolidación" },
      { number: 5, name: "Etapa 5 - Optimización y Escalamiento" },
      { number: 6, name: "Etapa 6 - Excelencia Operativa" }
    ]

    stages_definitions.each do |stage_def|
      stage = project.stages.create!(
        name: stage_def[:name], 
        position: stage_def[:number]
      )

      # CAMBIO: Ahora pasamos 'user' a cada método load_stage
      case stage_def[:number]
      when 1 then load_stage_1(stage, user)
      when 2 then load_stage_2(stage, user)
      when 3 then load_stage_3(stage, user)
      when 4 then load_stage_4(stage, user)
      when 5 then load_stage_5(stage, user)
      when 6 then load_stage_6(stage, user)
      end
    end
  end

  private

  # CAMBIO: El método 'add' ahora recibe 'user' como último argumento
  def self.add(stage, month, sequence, name, doc_ref = nil, description = nil, user)
    stage.activities.create!(
      month: month,
      week: sequence,
      name: name,
      document_ref: doc_ref,
      description: description,
      user: user, # Ahora 'user' sí está definido aquí
      completed: false
    )
  end

  # ==========================================
  # CARGA DE DATOS - ETAPA 1
  # ==========================================
  def self.load_stage_1(stage, user) # Recibe user
    # CAMBIO: Se agregó 'user' al final de cada llamada 'add'
    add(stage, 1, 1, "Solicitar y revisar expediente", "OPE-001 Check list de expediente inicial", nil, user)
    add(stage, 1, 2, "Realizar la ficha de datos básicos del cliente", "OPE-002 Ficha de datos del cliente", nil, user)
    add(stage, 1, 3, "Enviar autodiagnóstico '5 áreas clave'", "OPE-003 Autodiagnóstico", nil, user)
    add(stage, 1, 4, "Elaboración de dictamen de hallazgos según respuestas de autodiagnóstico", "OPE-008 Dictamen autodiagnóstico", nil, user)
    add(stage, 1, 5, "Kick off con dueño y líderes clave", "EST-003 Metodología Consilium", nil, user)
    add(stage, 1, 6, "Presentación al cliente plan de trabajo etapa 1", "OPE-004 Bitácora de inicio Kick off", nil, user)
    add(stage, 1, 7, "Evaluación de contexto de la empresa", "OPE-006 Preguntas contexto", nil, user)
    add(stage, 1, 9, "Presentación de dictamen inicial de hallazgos", "OPE-008 Dictamen de hallazgos", nil, user)
    add(stage, 1, 10, "Solicitar documentos clave", "OPE-009 Lista consolidada de información solicitada", nil, user)
    add(stage, 1, 11, "Sesión de validación de modelo de negocio", "OPE-010 Preguntas para modelo CANVAS", nil, user)
    add(stage, 1, 12, "Análisis y elaboración de modelo de negocio (CANVAS)", "OPE-010 / OPE-044 Modelo CANVAS", nil, user)
    add(stage, 1, 13, "Presentación de modelo de negocio", "OPE-044 / OPE-011 Minuta de reunión", nil, user)

    add(stage, 2, 14, "Sesión de solicitud de información para Alineación estratégica", "OPE-012 Guía de alineación estratégica", nil, user)
    add(stage, 2, 15, "Análisis y elaboración de modelo de alineación estratégica", "OPE-012 Guía de alineación estratégica", nil, user)
    add(stage, 2, 16, "Presentación de Alineación estratégica", "OPE-011 Minuta de reunión", nil, user)
    add(stage, 2, 17, "Sesión de validación de dependencia del dueño", "OPE-014 Dependencia del dueño", nil, user)
    add(stage, 2, 18, "Análisis y elaboración de propuestas de acciones correctivas", "OPE-014 Dependencia del dueño", nil, user)
    add(stage, 2, 19, "Presentación de resultados de dependencia del dueño", "OPE-011 Minuta de reunión", nil, user)

    add(stage, 3, 20, "Sesión de solicitud de información para elaboración de macroproceso y KPIs", "OPE-016 Base de datos macro proceso", nil, user)
    add(stage, 3, 21, "Análisis y elaboración de macro proceso y KPIs", "OPE-016 Base de datos macro proceso", nil, user)
    add(stage, 3, 22, "Presentación de macroproceso e indicadores clave", "OPE-011 Minuta de reunión", nil, user)
    add(stage, 3, 23, "Encuesta de clima organizacional", "OPE-043 Encuesta de clima organizacional", nil, user)
    add(stage, 3, 24, "Elaboración de plan a la medida (cronograma etapa 2)", "EST-003 Metodología Consilium", nil, user)
  end

  def self.load_stage_2(stage, user)
    add(stage, 4, 1, "Inicio Etapa 2 - (Pendiente de carga detallada)", "EST-003", nil, user)
  end

  def self.load_stage_3(stage, user)
    add(stage, 7, 1, "Inicio Etapa 3 - (Pendiente de carga detallada)", "EST-003", nil, user)
  end

  def self.load_stage_4(stage, user)
    add(stage, 10, 1, "Inicio Etapa 4 - (Pendiente de carga detallada)", "EST-003", nil, user)
  end

  def self.load_stage_5(stage, user)
    add(stage, 13, 1, "Inicio Etapa 5 - (Pendiente de carga detallada)", "EST-003", nil, user)
  end

  def self.load_stage_6(stage, user)
    add(stage, 16, 1, "Inicio Etapa 6 - (Pendiente de carga detallada)", "EST-003", nil, user)
  end
end