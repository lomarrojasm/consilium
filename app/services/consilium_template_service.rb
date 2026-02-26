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
  def self.load_stage_1(stage, user)
    add(stage, 1, 1, "Solicitar y revisar expediente", "OPE-001 Check list de expediente inicial", nil, user)
    add(stage, 1, 2, "Realizar la ficha de datos básicos del cliente", "OPE-002 Ficha de datos del cliente", nil, user)
    add(stage, 1, 3, "Enviar autodiagnóstico \"5 áreas clave\"", "OPE-003 Autodiagnóstico", nil, user)
    add(stage, 1, 4, "Elaboración de dictamen de hallazgos según respuestas de autodiagnóstico", "OPE-008 Dictamen autodiagnóstico", nil, user)
    add(stage, 1, 5, "Kick off con dueño y líderes clave", "EST-003 Metodología Consilium", nil, user)
    add(stage, 1, 6, "Presentación al cliente plan de trabajo etapa 1", "OPE-004 Bitácora de inicio Kick off", nil, user)
    add(stage, 1, 7, "Evaluación de contexto de la empresa", "OPE-006 Preguntas contexto", nil, user)
    add(stage, 1, 8, "Presentación de dictamen inicial de hallazgos", "OPE-008 Dictamen de hallazgos", nil, user)
    add(stage, 1, 9, "Solicitar documentos clave", "OPE-009 Lista consolidada de información solicitada", nil, user)
    add(stage, 1, 10, "Sesión de validación de modelo de negocio", "OPE-010 Preguntas para modelo CANVAS", nil, user)
    add(stage, 1, 11, "Análisis y elaboración de modelo de negocio (CANVAS)", "OPE-010 Preguntas para modelo CANVAS / OPE-044 Modelo CANVAS", nil, user)
    add(stage, 1, 12, "Presentación de modelo de negocio", "OPE-044 Modelo CANVAS / OPE-011 Minuta de reunión", nil, user)
    
    add(stage, 2, 13, "Sesión de solicitud de información para Alineación estratégica", "OPE-012 Guía de alineación estratégica", nil, user)
    add(stage, 2, 14, "Análisis y elaboración de modelo de alineación estratégica", "OPE-012 Guía de alineación estratégica", nil, user)
    add(stage, 2, 15, "Presentación de Alineación estratégica", "OPE-011 Minuta de reunión", nil, user)
    add(stage, 2, 16, "Sesión de validación de dependencia del dueño", "OPE-014 Dependencia del dueño", nil, user)
    add(stage, 2, 17, "Análisis y elaboración de propuestas de acciones correctivas", "OPE-014 Dependencia del dueño", nil, user)
    add(stage, 2, 18, "Presentación de resultados de dependencia del dueño", "OPE-011 Minuta de reunión", nil, user)
    
    add(stage, 3, 19, "Sesión de solicitud de información para elaboración de macroproceso y KPIs", "OPE-016 Base de datos macro proceso", nil, user)
    add(stage, 3, 20, "Análisis y elaboración de macro proceso y KPIs", "OPE-016 Base de datos macro proceso", nil, user)
    add(stage, 3, 21, "Presentación de macroproceso e indicadores clave", "OPE-011 Minuta de reunión", nil, user)
    add(stage, 3, 22, "Encuesta de clima organizacional", "OPE-043 Encuesta de clima organizacional", nil, user)
    add(stage, 3, 23, "Elaboración de plan a la medida (cronograma etapa 2)", "EST-003 Metodología Consilium", nil, user)
  end

  def self.load_stage_2(stage, user)
    add(stage, 1, 1, "Presentar plan de actividades de la etapa 2", "EST-003 Metodología Consilium", nil, user)
    add(stage, 1, 2, "Elaborar un sistema de gestión y seguimiento a KPIs principales (macro proceso)", "OPE-017 Sistema de seguimiento a KPIs (Macroproceso)", nil, user)
    add(stage, 1, 3, "Presentar y acordar periodicidad de seguimiento a KPIs principales (macroproceso)", "OPE-017 Sistema de seguimiento a KPIs (Macroproceso)", nil, user)
    add(stage, 1, 4, "Documentar y mapear procesos prioritarios", "OPE-018 Documentación de procesos", nil, user)
    add(stage, 1, 5, "Capacitacion en procesos implementados", "OPE-038 Hoja de datos de capacitacion", nil, user)
    
    add(stage, 2, 6, "Documentar políticas prioritarias", "OPE-019 Documentación de políticas", nil, user)
    add(stage, 2, 7, "Capacitacion en politicas documentadas", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 2, 8, "Matriz de responsabilidades (RACI)", "OPE-034 Matriz de responsabilidades (RACI)", nil, user)
    add(stage, 2, 9, "Organigrama", "Organigrama", nil, user)
    
    add(stage, 3, 10, "Detección de necesidades de capacitación", "OPE-037 Detección de necesidades de capacitación", nil, user)
    add(stage, 3, 11, "Capacitación Cómo trabajar por procesos (y elegir los más importantes)", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 3, 12, "Capacitación Mapa general de procesos y responsables de cada proceso", "OPE-038 Hoja de datos de capacitacion", nil, user)
    
    add(stage, 4, 13, "Capacitación Indicadores clave por proceso (qué medir y cómo medirlo)", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 4, 14, "Capacitación Juntas de seguimiento efectivas (acuerdos y responsables)", "OPE-038 Hoja de datos de capacitacion", nil, user)
    
    add(stage, 5, 15, "Identificación de segmentos y cliente ideal", "OPE-027 Formato de Identificación de segmentos y cliente ideal", nil, user)
    add(stage, 5, 16, "Estrategia comercial por segmento (1)", "OPE-028 Formato de estrategia comercial por segmento", nil, user)
    
    add(stage, 6, 17, "Estrategia comercial por segmento (2)", "OPE-028 Formato de estrategia comercial por segmento", nil, user)
    add(stage, 6, 18, "Estrategia comercial por segmento (3)", "OPE-028 Formato de estrategia comercial por segmento", nil, user)
    
    add(stage, 7, 19, "Alta y evaluación de proveedores", "OPE-029 Formato de alta y evaluación de proveedores", nil, user)
    add(stage, 7, 20, "Contrato con proveedores", "OPE-030 Formato de contrato con proveedores", nil, user)
    
    add(stage, 8, 21, "Carta responsiva de equipo de TI", "OPE-031 Carta responsiva de equipo de TI", nil, user)
    add(stage, 8, 22, "Perfil de puestos (Área/Gerencia 1)", "OPE-032 Perfil de puestos", nil, user)
    add(stage, 8, 23, "Perfil de puestos (Área/Gerencia 2)", "OPE-032 Perfil de puestos", nil, user)
    add(stage, 8, 24, "Perfil de puestos (Área/Gerencia 3)", "OPE-032 Perfil de puestos", nil, user)
    
    add(stage, 9, 25, "Perfil de puestos (Área/Gerencia 4)", "OPE-032 Perfil de puestos", nil, user)
    add(stage, 9, 26, "Perfil de puestos (Área/Gerencia 5)", "OPE-032 Perfil de puestos", nil, user)
    add(stage, 9, 27, "Matriz de gestión de empleados", "OPE-041 Matriz de gestión de empleados", nil, user)
    add(stage, 9, 28, "Elaboración de plan a la medida (cronograma etapa 3)", "EST-003 Metodología Consilium", nil, user)
  end

  def self.load_stage_3(stage, user)
    add(stage, 1, 1, "Presentar plan de actividades de la etapa 3", "EST-003 Metodología Consilium", nil, user)
    add(stage, 1, 2, "Matriz de responsabilidades (RACI)", "OPE-034 Matriz de responsabilidades (RACI)", nil, user)
    add(stage, 1, 3, "Actualizar y mejorar contrato individual", "OPE-035 Contrato individual", nil, user)
    add(stage, 1, 4, "Actualizar y mejorar reglamento interno de trabajo", "OPE-036 Reglamento interno de trabajo", nil, user)

    add(stage, 2, 5, "Detección de necesidades de capacitación", "OPE-037 Detección de necesidades de capacitación", nil, user)
    add(stage, 2, 6, "Capacitación cómo estandarizar la forma de trabajar (trabajo bien hecho)", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 2, 7, "Capacitación cómo hacer procedimientos simples (paso a paso)", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 2, 8, "Capacitación cómo usar checklists para asegurar calidad y consistencia", "OPE-038 Hoja de datos de capacitacion", nil, user)

    add(stage, 3, 9, "Capacitación control de documentos y formatos", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 3, 10, "Capacitación Scaling Up Fase 1", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 3, 11, "Plan Personal de una pagina Scaling Up", "SUP-001 Plan Personal de una pagina Scaling Up", nil, user)
    add(stage, 3, 12, "Tabla de responsabilidades por funcion Scaling Up", "SUP-002 Tabla de responsabilidades por funcion Scaling Up", nil, user)

    add(stage, 4, 13, "Tabla de responsabilidades por proceso Scaling Up", "SUP-003 Tabla de responsabilidades por proceso Scaling Up", nil, user)
    add(stage, 4, 14, "Formulario de fortalezas, debilidades y tendencias Scaling Up", "SUP-004 Formulario de fortalezas, debilidades y tendencias Scaling Up", nil, user)
    
    add(stage, 5, 15, "Documentación de politicas", "OPE-019 Documentación de politicas", nil, user)
    add(stage, 5, 16, "Capacitacion en politicas documentadas", "OPE-038 Hoja de datos de capacitacion", nil, user)

    add(stage, 6, 17, "Estandarización de procesos", nil, nil, user)
    add(stage, 6, 18, "Estandarización de procesos", "OPE-018 Documentación de procesos", nil, user)

    add(stage, 7, 19, "Estandarización de procesos", "OPE-018 Documentación de procesos", nil, user)
    add(stage, 7, 20, "Capacitacion en procesos implementados", "OPE-038 Hoja de datos de capacitacion", nil, user)

    add(stage, 8, 21, "Capacitación Scaling Up Fase 2", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 8, 22, "Estratos Scaling UP", "SUP-005 Estratos Scaling UP", nil, user)

    add(stage, 9, 23, "Plan estrategico de una pagina Scaling Up", "SUP-006 y SUP-007 Plan estrategico de una pagina Scaling Up", nil, user)
    add(stage, 9, 24, "Resumen de Vision Scaling Up", "SUP-008 Resumen de Vision Scaling Up", nil, user)

    add(stage, 10, 25, "Ejecucion quien, que cuando Scaling Up", "SUP-009 Ejecucion quien, que cuando Scaling Up", nil, user)
    add(stage, 10, 26, "Evaluacion de Los hábitos de Rockefeller", "SUP-010 Evaluacion de Los hábitos de Rockefeller", nil, user)

    add(stage, 11, 27, "Estrategias de acelerecion de efectivo", "SUP-011 Estrategias de acelerecion de efectivo", nil, user)
    add(stage, 11, 28, "El poder del uno Scaling Up", "SUP-012 El poder del uno Scaling Up", nil, user)

    add(stage, 12, 29, "Retroalimentacion de Scaling Up", "OPE-041 Hoja de datos de capacitación", nil, user)
    add(stage, 12, 30, "Elaboración de plan a la medida (cronograma etapa 4)", "EST-003 Metodología Consilium", nil, user)
  end

  def self.load_stage_4(stage, user)
    add(stage, 1, 1, "Presentar plan de actividades de la etapa 4", "EST-003 Metodología Consilium", nil, user)
    add(stage, 1, 2, "Enviar autodiagnóstico \"5 áreas clave\"", "OPE-003 Autodiagnóstico", nil, user)
    add(stage, 1, 3, "Analizar resultado y elaborar dictamen", "OPE-008 Dictamen de hallazgos", nil, user)
    add(stage, 1, 4, "Presentar Dictamen de autodiagnóstico", "OPE-008 Dictamen de hallazgos", nil, user)

    add(stage, 2, 5, "Plan Personal de una pagina Scaling Up", "SUP-001 Plan Personal de una pagina Scaling Up", nil, user)
    add(stage, 2, 6, "Tabla de responsabilidades por función Scaling Up", "SUP-002 Tabla de responsabilidades por función Scaling Up", nil, user)
    add(stage, 2, 7, "Tabla de responsabilidades por proceso Scaling Up", "SUP-003 Tabla de responsabilidades por proceso Scaling Up", nil, user)
    add(stage, 2, 8, "Formulario de fortalezas, debilidades y tendencias Scaling Up", "SUP-004 Formulario de fortalezas, debilidades y tendencias Scaling Up", nil, user)

    add(stage, 3, 9, "Detección de necesidades de capacitación", "OPE-037 Detección de necesidades de capacitación", nil, user)
    add(stage, 3, 10, "Capacitación Mejora continua práctica (cómo mejorar paso a paso)", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 3, 11, "Capacitación Encontrar la causa real de los problemas (5 porqués / diagrama simple)", "OPE-038 Hoja de datos de capacitacion", nil, user)

    add(stage, 4, 12, "Capacitación Resolver problemas de forma ordenada (método A3/8D sencillo)", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 4, 13, "Capacitación Seguimiento de acciones correctivas (pendientes, responsables y verificación)", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 4, 14, "Actualizar validación de modelo de negocio (CANVA)", "OPE-010 Preguntas para modelo CANVAS", nil, user)

    add(stage, 5, 15, "Actualizar Alineación estratégica", "OPE-012 Guía de alineación estratégica", nil, user)
    add(stage, 5, 16, "Actualizar evaluación de dependencia del dueño", "OPE-013 Dependencia del dueño", nil, user)
    add(stage, 5, 17, "Actualizar macroproceso, dueños de proceso y KPIs", "OPE-016 Base de datos macro proceso", nil, user)
    add(stage, 5, 18, "Auditorias y conciliaciones aleatorias (Identificar si hubo fugas de dinero)", "OPE-020 Conciliación / Paretto de gastos OPE-023", nil, user)

    add(stage, 6, 19, "Análisis de flujo de efectivo (trimestre)", "OPE-022 Flujo de efectivo 13 semanas", nil, user)
    add(stage, 6, 20, "Análisis de pendientes por cobrar, rentabilidad y margen", "OPE-023 Estado de resultados (3 meses)", nil, user)
    add(stage, 6, 21, "Presentar dictamen financiero y acciones correctivas", "OPE-024 Dictamen financiero", nil, user)
    add(stage, 6, 22, "Identificar segmentos y cliente ideal", "OPE-027 Formato de Identificación de segmentos y cliente ideal", nil, user)

    add(stage, 7, 23, "Estrategia comercial por segmento (1)", "OPE-028 Formato de estrategia comercial por segmento", nil, user)
    add(stage, 7, 24, "Estrategia comercial por segmento (2)", "OPE-028 Formato de estrategia comercial por segmento", nil, user)

    add(stage, 8, 25, "Estrategia comercial por segmento (3)", "OPE-028 Formato de estrategia comercial por segmento", nil, user)
    add(stage, 8, 26, "Auditoria a proveedores", "OPE-029 Formato de alta y evaluación de proveedores", nil, user)
    add(stage, 8, 27, "Auditoría a equipo de TI", "OPE-031 Carta responsiva de equipo de TI", nil, user)

    add(stage, 9, 28, "Actualizar perfiles de puesto (Área/ gerencia 1 y 2)", "OPE-032 Perfil de puestos", nil, user)
    add(stage, 9, 29, "Actualizar perfiles de puesto (Área/ gerencia 3 ,4 y 5)", "OPE-032 Perfil de puestos", nil, user)
    add(stage, 9, 30, "Actualizar organigrama", "OPE-033 Organigrama finalizado", nil, user)
    add(stage, 9, 31, "Actualizar matriz RACI", "OPE-034 Matriz de responsabilidades (RACI)", nil, user)

    add(stage, 10, 32, "Actualizar y mejorar contrato individual", "OPE-035 Contrato individual", nil, user)
    add(stage, 10, 33, "Actualizar y mejorar reglamento interno de trabajo", "OPE-036 Reglamento interno de trabajo", nil, user)
    add(stage, 10, 34, "Encuesta de clima organizacional", "OPE-043 Encuesta de clima organizacional", nil, user)

    add(stage, 11, 35, "Estandarización de procesos", "OPE-018 Documentación de procesos", nil, user)
    add(stage, 11, 36, "Estandarización de procesos", "OPE-018 Documentación de procesos", nil, user)
    add(stage, 11, 37, "Estandarización de procesos", "OPE-018 Documentación de procesos", nil, user)
    add(stage, 11, 38, "Capacitación en procesos implementados", "OPE-038 Hoja de datos de capacitacion", nil, user)

    add(stage, 12, 39, "Documentación de políticas", "OPE-019 Documentación de políticas", nil, user)
    add(stage, 12, 40, "Documentación de políticas", "OPE-019 Documentación de políticas", nil, user)
    add(stage, 12, 41, "Capacitación en políticas implementadas", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 12, 42, "Elaboración de plan a la medida (cronograma etapa 5)", "EST-003 Metodología Consilium", nil, user)
  end

  def self.load_stage_5(stage, user)
    add(stage, 1, 1, "Presentar plan de actividades de la etapa 4", "EST-003 Metodología Consilium", nil, user)
    add(stage, 1, 2, "Enviar autodiagnóstico \"5 áreas clave\"", "OPE-003 Autodiagnóstico", nil, user)
    add(stage, 1, 3, "Analizar resultado y elaborar dictamen", "OPE-008 Dictamen de hallazgos", nil, user)
    add(stage, 1, 4, "Presentar Dictamen de autodiagnóstico", "OPE-008 Dictamen de hallazgos", nil, user)

    add(stage, 2, 5, "Capacitación Scaling Up Fase 2", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 2, 6, "Estratos Scaling UP", "SUP-005 Estratos Scaling UP", nil, user)
    add(stage, 2, 7, "Plan estrategico de una pagina Scaling Up", "SUP-006 y SUP-007 Plan estrategico de una pagina Scaling Up", nil, user)
    add(stage, 2, 8, "Resumen de Vision Scaling Up", "SUP-008 Resumen de Vision Scaling Up", nil, user)

    add(stage, 3, 9, "Detección de necesidades de capacitación", "OPE-037 Detección de necesidades de capacitación", nil, user)
    add(stage, 3, 10, "Cómo hacer la operación más eficiente", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 3, 11, "Detectar y romper cuellos de botella", "OPE-038 Hoja de datos de capacitacion", nil, user)

    add(stage, 4, 12, "Optimización del flujo de trabajo (recorridos, secuencias y layout)", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 4, 13, "Estandarizar para crecer (misma forma de trabajar en todos los equipos/sedes)", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 4, 14, "Actualizar validación de modelo de negocio (CANVA)", "OPE-010 Preguntas para modelo CANVAS", nil, user)

    add(stage, 5, 15, "Actualizar Alineación estratégica", "OPE-012 Guía de alineación estratégica", nil, user)
    add(stage, 5, 16, "Actualizar evaluación de dependencia del dueño", "OPE-013 Dependencia del dueño", nil, user)
    add(stage, 5, 17, "Actualizar macroproceso, dueños de proceso y KPIs", "OPE-016 Base de datos macro proceso", nil, user)
    add(stage, 5, 18, "Auditorias y conciliaciones aleatorias (Identificar si hubo fugas de dinero)", "OPE-020 Conciliación / Paretto de gastos OPE-023", nil, user)

    add(stage, 6, 19, "Análisis de flujo de efectivo (trimestre)", "OPE-022 Flujo de efectivo 13 semanas", nil, user)
    add(stage, 6, 20, "Análisis de pendientes por cobrar, rentabilidad y margen", "OPE-023 Estado de resultados (3 meses)", nil, user)
    add(stage, 6, 21, "Presentar dictamen financiero y acciones correctivas", "OPE-024 Dictamen financiero", nil, user)
    add(stage, 6, 22, "Identificar segmentos y cliente ideal", "OPE-027 Formato de Identificación de segmentos y cliente ideal", nil, user)

    add(stage, 7, 23, "Estrategia comercial por segmento (1)", "OPE-028 Formato de estrategia comercial por segmento", nil, user)
    add(stage, 7, 24, "Estrategia comercial por segmento (2)", "OPE-028 Formato de estrategia comercial por segmento", nil, user)

    add(stage, 8, 25, "Estrategia comercial por segmento (3)", "OPE-028 Formato de estrategia comercial por segmento", nil, user)
    add(stage, 8, 26, "Auditoria a proveedores", "OPE-029 Formato de alta y evaluación de proveedores", nil, user)
    add(stage, 8, 27, "Auditoría a equipo de TI", "OPE-031 Carta responsiva de equipo de TI", nil, user)

    add(stage, 9, 28, "Actualizar perfiles de puesto (Área/ gerencia 1 y 2)", "OPE-032 Perfil de puestos", nil, user)
    add(stage, 9, 29, "Actualizar perfiles de puesto (Área/ gerencia 3 ,4 y 5)", "OPE-032 Perfil de puestos", nil, user)
    add(stage, 9, 30, "Actualizar organigrama", "OPE-033 Organigrama finalizado", nil, user)
    add(stage, 9, 31, "Actualizar matriz RACI", "OPE-034 Matriz de responsabilidades (RACI)", nil, user)

    add(stage, 10, 32, "Actualizar y mejorar contrato individual", "OPE-035 Contrato individual", nil, user)
    add(stage, 10, 33, "Actualizar y mejorar reglamento interno de trabajo", "OPE-036 Reglamento interno de trabajo", nil, user)
    add(stage, 10, 34, "Encuesta de clima organizacional", "OPE-039 Hoja de requisitos de página web", nil, user)

    add(stage, 11, 35, "Estandarización de procesos", "OPE-018 Documentación de procesos", nil, user)
    add(stage, 11, 36, "Estandarización de procesos", "OPE-018 Documentación de procesos", nil, user)
    add(stage, 11, 37, "Estandarización de procesos", "OPE-018 Documentación de procesos", nil, user)
    add(stage, 11, 38, "Capacitación en procesos implementados", "OPE-038 Hoja de datos de capacitacion", nil, user)

    add(stage, 12, 39, "Documentación de politicas", "OPE-019 Documentación de políticas", nil, user)
    add(stage, 12, 40, "Documentación de politicas", "OPE-019 Documentación de políticas", nil, user)
    add(stage, 12, 41, "Capacitación en políticas implementadas", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 12, 42, "Elaboración de plan a la medida (cronograma etapa 5)", "EST-003 Metodología Consilium", nil, user)
  end

  def self.load_stage_6(stage, user)
    add(stage, 1, 1, "Presentar plan de actividades de la etapa 4", "EST-003 Metodología Consilium", nil, user)
    add(stage, 1, 2, "Enviar autodiagnóstico \"5 áreas clave\"", "OPE-003 Autodiagnóstico", nil, user)
    add(stage, 1, 3, "Analizar resultado y elaborar dictamen", "OPE-008 Dictamen de hallazgos", nil, user)
    add(stage, 1, 4, "Presentar Dictamen de autodiagnóstico", "OPE-008 Dictamen de hallazgos", nil, user)

    add(stage, 2, 5, "Ejecucion quien, que cuando Scaling Up", "SUP-009 Ejecucion quien, que cuando Scaling Up", nil, user)
    add(stage, 2, 6, "Evaluacion de Los hábitos de Rockefeller", "SUP-010 Evaluacion de Los hábitos de Rockefeller", nil, user)
    add(stage, 2, 7, "Estrategias de acelerecion de efectivo", "SUP-011 Estrategias de acelerecion de efectivo", nil, user)
    add(stage, 2, 8, "El poder del uno Scaling Up", "SUP-012 El poder del uno Scaling Up", nil, user)

    add(stage, 3, 9, "Detección de necesidades de capacitación", "OPE-037 Detección de necesidades de capacitación", nil, user)
    add(stage, 3, 10, "Reglas claras de operación y toma de decisiones (gobernanza)", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 3, 11, "Delegación y continuidad (manuales y plan de reemplazos)", "OPE-038 Hoja de datos de capacitacion", nil, user)

    add(stage, 4, 12, "Prevenir riesgos y errores repetitivos (controles internos simples)", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 4, 13, "Gestión de proyectos y mejoras (prioridades y resultados)", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 4, 14, "Actualizar validación de modelo de negocio (CANVA)", "OPE-010 Preguntas para modelo CANVAS", nil, user)

    add(stage, 5, 15, "Actualizar Alineación estratégica", "OPE-012 Guía de alineación estratégica", nil, user)
    add(stage, 5, 16, "Actualizar evaluación de dependencia del dueño", "OPE-013 Dependencia del dueño", nil, user)
    add(stage, 5, 17, "Actualizar macroproceso, dueños de proceso y KPIs", "OPE-016 Base de datos macro proceso", nil, user)
    add(stage, 5, 18, "Auditorias y conciliaciones aleatorias (Identificar si hubo fugas de dinero)", "OPE-020 Conciliación / Paretto de gastos OPE-023", nil, user)

    add(stage, 6, 19, "Análisis de flujo de efectivo (trimestre)", "OPE-022 Flujo de efectivo 13 semanas", nil, user)
    add(stage, 6, 20, "Análisis de pendientes por cobrar, rentabilidad y margen", "OPE-023 Estado de resultados (3 meses)", nil, user)
    add(stage, 6, 21, "Presentar dictamen financiero y acciones correctivas", "OPE-024 Dictamen financiero", nil, user)
    add(stage, 6, 22, "Identificar segmentos y cliente ideal", "OPE-027 Formato de Identificación de segmentos y cliente ideal", nil, user)

    add(stage, 7, 23, "Estrategia comercial por segmento (1)", "OPE-028 Formato de estrategia comercial por segmento", nil, user)
    add(stage, 7, 24, "Estrategia comercial por segmento (2)", "OPE-028 Formato de estrategia comercial por segmento", nil, user)

    add(stage, 8, 25, "Estrategia comercial por segmento (3)", "OPE-028 Formato de estrategia comercial por segmento", nil, user)
    add(stage, 8, 26, "Auditoria a proveedores", "OPE-029 Formato de alta y evaluación de proveedores", nil, user)
    add(stage, 8, 27, "Auditoría a equipo de TI", "OPE-031 Carta responsiva de equipo de TI", nil, user)

    add(stage, 9, 28, "Actualizar perfiles de puesto (Área/ gerencia 1 y 2)", "OPE-032 Perfil de puestos", nil, user)
    add(stage, 9, 29, "Actualizar perfiles de puesto (Área/ gerencia 3 ,4 y 5)", "OPE-032 Perfil de puestos", nil, user)
    add(stage, 9, 30, "Actualizar organigrama", "OPE-033 Organigrama finalizado", nil, user)
    add(stage, 9, 31, "Actualizar matriz RACI", "OPE-034 Matriz de responsabilidades (RACI)", nil, user)

    add(stage, 10, 32, "Actualizar y mejorar contrato individual", "OPE-035 Contrato individual", nil, user)
    add(stage, 10, 33, "Actualizar y mejorar reglamento interno de trabajo", "OPE-036 Reglamento interno de trabajo", nil, user)
    add(stage, 10, 34, "Encuesta de clima organizacional", "OPE-039 Hoja de requisitos de página web", nil, user)

    add(stage, 11, 35, "Estandarización de procesos", "OPE-018 Documentación de procesos", nil, user)
    add(stage, 11, 36, "Estandarización de procesos", "OPE-018 Documentación de procesos", nil, user)
    add(stage, 11, 37, "Estandarización de procesos", "OPE-018 Documentación de procesos", nil, user)
    add(stage, 11, 38, "Capacitación en procesos implementados", "OPE-038 Hoja de datos de capacitacion", nil, user)

    add(stage, 12, 39, "Documentación de politicas", "OPE-019 Documentación de políticas", nil, user)
    add(stage, 12, 40, "Documentación de politicas", "OPE-019 Documentación de políticas", nil, user)
    add(stage, 12, 41, "Capacitación en políticas implementadas", "OPE-038 Hoja de datos de capacitacion", nil, user)
    add(stage, 12, 42, "Elaboración de plan a la medida (cronograma etapa 5)", "EST-003 Metodología Consilium", nil, user)
  end
end