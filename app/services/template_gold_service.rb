class TemplateGoldService
  def self.generate(project, user)
    # 1. Creación de Etapas
    stages_definitions = [
      "Etapa 1 - Alinear y Diagnosticar",
      "Etapa 2 - Ordenar y Controlar",
      "Etapa 3 - Estandarizar y Profesionalizar",
      "Etapa 4 - Mejora Continua y Consolidación",
      "Etapa 5 - Optimización y Escalamiento",
      "Etapa 6 - Excelencia Operativa"
    ]

    stages_hash = {}
    stages_definitions.each_with_index do |name, i|
      stages_hash[i + 1] = project.stages.find_or_create_by!(position: i + 1, name: name)
    end

    # 2. Base de Datos Estática (Matriz Extraída de MembresiaGold.xlsx)
    # Formato: [Etapa, Mes, Semana, "Actividad", "Documento", "Áreas", Tarifa L, Tarifa S, Tarifa A, Hrs L, Hrs S, Hrs A]
    actividades = [
      # --- ETAPA 1 (24 Tareas) ---
      [1, 1, 1, "Diagnóstico para membresía", "OPE-020 Diagnóstico para membresía", "Integral", 1250, 850, 450, 0, 0, 1],
      [1, 1, 1, "Solicitar y revisar expediente", "OPE-001 Check list de expediente inicial", "Integral", 1250, 850, 450, 3, 2, 2],
      [1, 1, 1, "Realizar la ficha de datos básicos del cliente", "OPE-002 Ficha de datos del cliente", "Integral", 1250, 850, 450, 2, 2, 2],
      [1, 1, 1, "Enviar autodiagnóstico '5 áreas clave'", "OPE-003 Autodiagnóstico", "Integral", 1250, 850, 450, 2, 1, 2],
      [1, 1, 2, "Elaboración de dictamen de hallazgos según respuestas de autodiagnóstico", "OPE-008 Dictamen autodiagnóstico", "Integral", 1250, 850, 450, 2, 1, 2],
      [1, 1, 2, "Kick off con dueño y líderes clave", "EST-003 Metodología Consilium", "Integral", 1250, 850, 450, 2, 1, 6],
      [1, 1, 2, "Presentación al cliente plan de trabajo etapa 1", "OPE-004 Bitácora de inicio Kick off", "Integral", 1250, 850, 450, 2, 2, 2],
      [1, 1, 2, "Evaluación de contexto de la empresa", "OPE-006 Preguntas contexto", "Integral", 1250, 850, 450, 1, 1, 1],
      [1, 1, 2, "Presentación de dictamen inicial de hallazgos", "OPE-008 Dictamen de hallazgos", "Integral", 1250, 850, 450, 1, 1, 1],
      [1, 1, 3, "Solicitar documentos clave", "OPE-009 Lista consolidada de información solicitada", "Integral", 1250, 850, 450, 2, 1, 3],
      [1, 1, 3, "Sesión de validación de modelo de negocio", "OPE-010 Preguntas para modelo CANVAS", "Dirección, Procesos, Comercial", 1250, 850, 450, 2, 2, 2],
      [1, 1, 4, "Análisis y elaboración de modelo de negocio (CANVAS)", "OPE-010 Preguntas para modelo CANVAS / OPE-044 Modelo CANVAS", "Dirección, Procesos, Comercial", 1250, 850, 450, 1, 4, 4],
      [1, 1, 4, "Presentación de modelo de negocio", "OPE-044 Modelo CANVAS / OPE-011 Minuta de reunión", "Dirección, Procesos, Comercial", 1250, 850, 450, 2, 2, 2],
      [1, 2, 1, "Sesión de solicitud de información para Alineación estratégica", "OPE-012 Guía de alineación estratégica", "Dirección", 1250, 850, 450, 2, 2, 2],
      [1, 2, 1, "Análisis y elaboración de modelo de alineación estratégica", "OPE-012 Guía de alineación estratégica", "Dirección", 1250, 850, 450, 2, 4, 4],
      [1, 2, 1, "Presentación de Alineación estratégica", "OPE-011 Minuta de reunión", "Dirección", 1250, 850, 450, 2, 2, 2],
      [1, 2, 2, "Sesión de validación de dependencia del dueño", "OPE-014 Dependencia del dueño", "Dirección", 1250, 850, 450, 2, 2, 2],
      [1, 2, 2, "Análisis y elaboración de propuestas de acciones correctivas", "OPE-014 Dependencia del dueño", "Dirección", 1250, 850, 450, 4, 4, 4],
      [1, 2, 2, "Presentación de resultados de dependencia del dueño", "OPE-011 Minuta de reunión", "Dirección", 1250, 850, 450, 2, 2, 0],
      [1, 3, 3, "Sesión de solicitud de información para elaboración de macroproceso y KPIs", "OPE-016 Base de datos macro proceso", "Procesos", 1250, 850, 450, 4, 4, 4],
      [1, 3, 3, "Análisis y elaboración de macro proceso y KPIs", "OPE-016 Base de datos macro proceso", "Procesos", 1250, 850, 450, 2, 8, 8],
      [1, 3, 4, "Presentación de macroproceso e indicadores clave", "OPE-011 Minuta de reunión", "Procesos", 1250, 850, 450, 2, 2, 2],
      [1, 3, 4, "Encuesta de clima organizacional", "OPE-043 Encuesta de clima organizacional", "RH", 1250, 850, 450, 2, 2, 2],
      [1, 3, 4, "Elaboración de plan a la medida (cronograma etapa 2)", "EST-003 Metodología Consilium", "Integral", 1250, 850, 450, 2, 2, 2],

      # --- ETAPA 2 (30 Tareas) ---
      [2, 1, 1, "Presentar plan de actividades de la etapa 2", "EST-003 Metodología Consilium", "Integral", 1250, 850, 450, 2, 2, 2],
      [2, 1, 2, "Elaborar un sistema de gestión y seguimiento a KPIs principales (macro proceso)", "OPE-017 Sistema de seguimiento a KPIs (Macroproceso)", "Integral", 1250, 850, 450, 4, 8, 16],
      [2, 1, 3, "Presentar y acordar periodicidad de seguimiento a KPIs principales (macroproceso)", "OPE-017 Sistema de seguimiento a KPIs (Macroproceso)", "Integral", 1250, 850, 450, 4, 4, 2],
      [2, 1, 4, "Documentar y mapear procesos prioritarios", "OPE-018 Documentación de procesos", "Procesos", 1250, 850, 450, 8, 12, 24],
      [2, 2, 1, "Capacitación en procesos implementados", "OPE-038 Hoja de datos de capacitación", "Procesos", 1250, 850, 450, 8, 12, 24],
      [2, 2, 2, "Documentar políticas prioritarias", "OPE-019 Documentación de políticas", "Procesos", 1250, 850, 450, 2, 8, 8],
      [2, 2, 3, "Capacitación en políticas documentadas", "OPE-038 Hoja de datos de capacitación", "Procesos", 1250, 850, 450, 2, 8, 8],
      [2, 3, 1, "Matriz de responsabilidades (RACI)", "OPE-034 Matriz de responsabilidades (RACI)", "RH", 1250, 850, 450, 2, 8, 8],
      [2, 3, 2, "Organigrama", "Organigrama", "RH", 1250, 850, 450, 2, 2, 2],
      [2, 3, 3, "Capacitación y comunicación de matriz de responsabilidades y estructura organizacional", "OPE-038 Hoja de datos de capacitación", "RH", 1250, 850, 450, 4, 8, 16],
      [2, 3, 4, "Detección de necesidades de capacitación", "OPE-037 Detección de necesidades de capacitación", "Procesos", 1250, 850, 450, 2, 2, 2],
      [2, 4, 1, "Capacitación Cómo trabajar por procesos (y elegir los más importantes)", "OPE-038 Hoja de datos de capacitación", "Procesos", 1250, 850, 450, 4, 12, 24],
      [2, 4, 2, "Capacitación Mapa general de procesos y responsables de cada proceso", "OPE-038 Hoja de datos de capacitación", "Procesos", 1250, 850, 450, 4, 12, 24],
      [2, 4, 3, "Capacitación Indicadores clave por proceso (qué medir y cómo medirlo)", "OPE-038 Hoja de datos de capacitación", "Procesos", 1250, 850, 450, 4, 12, 24],
      [2, 4, 4, "Capacitación Juntas de seguimiento efectivas (acuerdos y responsables)", "OPE-038 Hoja de datos de capacitación", "Procesos", 1250, 850, 450, 4, 12, 24],
      [2, 5, 1, "Identificación de segmentos y cliente ideal", "OPE-027 Formato de Identificación de segmentos y cliente ideal", "Comercial", 1250, 850, 450, 4, 8, 16],
      [2, 5, 2, "Estrategia comercial por segmento (1)", "OPE-028 Formato de estrategia comercial por segmento", "Comercial", 1250, 850, 450, 4, 12, 24],
      [2, 6, 1, "Estrategia comercial por segmento (2)", "OPE-028 Formato de estrategia comercial por segmento", "Comercial", 1250, 850, 450, 4, 12, 24],
      [2, 6, 2, "Estrategia comercial por segmento (3)", "OPE-028 Formato de estrategia comercial por segmento", "Comercial", 1250, 850, 450, 4, 12, 24],
      [2, 7, 1, "Alta y evaluación de proveedores", "OPE-029 Formato de alta y evaluación de proveedores", "Procesos", 1250, 850, 450, 0, 4, 12],
      [2, 7, 2, "Contrato con proveedores", "OPE-030 Formato de contrato con proveedores", "Procesos", 1250, 850, 450, 2, 4, 12],
      [2, 8, 1, "Carta responsiva de equipo de TI", "OPE-031 Carta responsiva de equipo de TI", "Procesos, RH", 1250, 850, 450, 1, 2, 12],
      [2, 8, 2, "Perfil de puestos (Área/Gerencia 1)", "OPE-032 Perfil de puestos", "Dirección", 1250, 850, 450, 1, 2, 8],
      [2, 8, 3, "Perfil de puestos (Área/Gerencia 2)", "OPE-032 Perfil de puestos", "Finanzas", 1250, 850, 450, 1, 2, 8],
      [2, 8, 4, "Perfil de puestos (Área/Gerencia 3)", "OPE-032 Perfil de puestos", "Procesos", 1250, 850, 450, 1, 2, 8],
      [2, 9, 1, "Perfil de puestos (Área/Gerencia 4)", "OPE-032 Perfil de puestos", "Comercial", 1250, 850, 450, 1, 2, 8],
      [2, 9, 2, "Perfil de puestos (Área/Gerencia 5)", "OPE-032 Perfil de puestos", "RH", 1250, 850, 450, 1, 2, 8],
      [2, 9, 3, "Matriz de gestión de empleados", "OPE-041 Matriz de gestión de empleados", "RH", 1250, 850, 450, 1, 2, 2],
      [2, 9, 4, "Diagnóstico para membresía", "OPE-020 Diagnóstico para membresía", "Integral", 1250, 850, 450, 2, 4, 16],
      [2, 9, 4, "Elaboración de plan a la medida (cronograma etapa 3)", "EST-003 Metodología Consilium", "Integral", 1250, 850, 450, 1, 2, 2],

      # --- ETAPA 3 (32 Tareas) ---
      [3, 1, 1, "Presentar plan de actividades de la etapa 3", "EST-003 Metodología Consilium", "Integral", 1250, 850, 450, 2, 2, 2],
      [3, 1, 2, "Matriz de responsabilidades (RACI)", "OPE-034 Matriz de responsabilidades (RACI)", "Integral", 1250, 850, 450, 1, 4, 12],
      [3, 1, 3, "Actualizar y mejorar contrato individual", "OPE-035 Contrato individual", "RH", 1250, 850, 450, 2, 2, 8],
      [3, 1, 4, "Actualizar y mejorar reglamento interno de trabajo", "OPE-036 Reglamento interno de trabajo", "RH", 1250, 850, 450, 2, 2, 8],
      [3, 2, 1, "Detección de necesidades de capacitación", "OPE-037 Detección de necesidades de capacitación", "Integral", 1250, 850, 450, 2, 2, 6],
      [3, 2, 2, "Capacitación cómo estandarizar la forma de trabajar (trabajo bien hecho)", "OPE-038 Hoja de datos de capacitación", "Procesos", 1250, 850, 450, 2, 2, 6],
      [3, 2, 3, "Capacitación cómo hacer procedimientos simples (paso a paso)", "OPE-038 Hoja de datos de capacitación", "Procesos", 1250, 850, 450, 2, 2, 6],
      [3, 2, 4, "Capacitación cómo usar checklists para asegurar calidad y consistencia", "OPE-038 Hoja de datos de capacitación", "Procesos", 1250, 850, 450, 2, 2, 6],
      [3, 3, 1, "Capacitación control de documentos y formatos", "OPE-038 Hoja de datos de capacitación", "Procesos", 1250, 850, 450, 2, 2, 6],
      [3, 3, 2, "Capacitación Scaling Up Fase 1", "OPE-038 Hoja de datos de capacitación", "Dirección", 1250, 850, 450, 4, 4, 4],
      [3, 3, 3, "Plan Personal de una pagina Scaling Up", "SUP-001 Plan Personal de una pagina Scaling Up", "Dirección", 1250, 850, 450, 4, 4, 4],
      [3, 3, 4, "Tabla de responsabilidades por función Scaling Up", "SUP-002 Tabla de responsabilidades por función Scaling Up", "Dirección, Procesos, RH", 1250, 850, 450, 4, 4, 4],
      [3, 4, 1, "Tabla de responsabilidades por proceso Scaling Up", "SUP-003 Tabla de responsabilidades por proceso Scaling Up", "Dirección, Procesos, RH", 1250, 850, 450, 4, 4, 4],
      [3, 4, 2, "Formulario de fortalezas, debilidades y tendencias Scaling Up", "SUP-004 Formulario de fortalezas, debilidades y tendencias Scaling Up", "Dirección", 1250, 850, 450, 2, 2, 6],
      [3, 4, 3, "Documentación de políticas", "OPE-019 Documentación de políticas", "Dirección, Procesos", 1250, 850, 450, 4, 8, 24],
      [3, 5, 1, "Documentación de políticas", "OPE-019 Documentación de políticas", "Dirección, Procesos", 1250, 850, 450, 4, 8, 24],
      [3, 5, 2, "Capacitación en políticas documentadas", "OPE-038 Hoja de datos de capacitación", "Dirección, Procesos", 1250, 850, 450, 4, 8, 24],
      [3, 6, 1, "Estandarización de procesos", "OPE-018 Documentación de procesos", "Dirección, Procesos", 1250, 850, 450, 4, 8, 24],
      [3, 6, 2, "Estandarización de procesos", "OPE-018 Documentación de procesos", "Dirección, Procesos", 1250, 850, 450, 4, 8, 24],
      [3, 7, 1, "Estandarización de procesos", "OPE-018 Documentación de procesos", "Dirección, Procesos", 1250, 850, 450, 2, 4, 12],
      [3, 7, 2, "Capacitación en procesos implementados", "OPE-038 Hoja de datos de capacitación", "Dirección, Procesos", 1250, 850, 450, 2, 12, 48],
      [3, 8, 1, "Capacitación Scaling Up Fase 2", "OPE-038 Hoja de datos de capacitación", "Dirección", 1250, 850, 450, 8, 8, 8],
      [3, 8, 2, "Estratos Scaling UP", "SUP-005 Estratos Scaling UP", "Dirección", 1250, 850, 450, 4, 4, 4],
      [3, 9, 1, "Plan estratégico de una pagina Scaling Up", "SUP-006 y SUP-007 Plan estratégico de una pagina Scaling Up", "Dirección, Comercial", 1250, 850, 450, 4, 4, 4],
      [3, 9, 2, "Resumen de Visión Scaling Up", "SUP-008 Resumen de Visión Scaling Up", "Dirección", 1250, 850, 450, 4, 4, 4],
      [3, 10, 1, "Ejecución quien, que cuando Scaling Up", "SUP-009 Ejecución quien, que cuando Scaling Up", "Dirección, RH", 1250, 850, 450, 4, 4, 4],
      [3, 10, 2, "Evaluación de Los hábitos de Rockefeller", "SUP-010 Evaluación de Los hábitos de Rockefeller", "Finanzas", 1250, 850, 450, 4, 4, 4],
      [3, 11, 1, "Estrategias de aceleración de efectivo", "SUP-011 Estrategias de aceleración de efectivo", "Finanzas", 1250, 850, 450, 4, 4, 4],
      [3, 11, 2, "El poder del uno Scaling Up", "SUP-012 El poder del uno Scaling Up", "Finanzas", 1250, 850, 450, 4, 4, 4],
      [3, 12, 1, "Retroalimentación de Scaling Up", "OPE-041 Hoja de datos de capacitación", "Integral", 1250, 850, 450, 4, 12, 48],
      [3, 12, 2, "Elaboración de plan a la medida (cronograma etapa 4)", "EST-003 Metodología Consilium", "Integral", 1250, 850, 450, 1, 2, 2],
      [3, 12, 3, "Diagnóstico para membresía", "OPE-020 Diagnóstico para membresía", "Integral", 1250, 850, 450, 0, 0, 1],

      # --- ETAPA 4 (43 Tareas) ---
      [4, 1, 1, "Presentar plan de actividades de la etapa 4", "EST-003 Metodología Consilium", "Integral", 1250, 850, 450, 2, 2, 2],
      [4, 1, 2, "Enviar autodiagnóstico '5 áreas clave'", "OPE-003 Autodiagnóstico", "Integral", 1250, 850, 450, 1, 1, 1],
      [4, 1, 3, "Analizar resultado y elaborar dictamen", "OPE-008 Dictamen de hallazgos", "Integral", 1250, 850, 450, 2, 2, 8],
      [4, 1, 4, "Presentar Dictamen de autodiagnóstico", "OPE-008 Dictamen de hallazgos", "Integral", 1250, 850, 450, 2, 2, 2],
      [4, 2, 1, "Plan Personal de una pagina Scaling Up", "SUP-001 Plan Personal de una pagina Scaling Up", "Dirección", 1250, 850, 450, 4, 4, 4],
      [4, 2, 2, "Tabla de responsabilidades por función Scaling Up", "SUP-002 Tabla de responsabilidades por función Scaling Up", "Dirección, Procesos, RH", 1250, 850, 450, 4, 4, 4],
      [4, 2, 3, "Tabla de responsabilidades por proceso Scaling Up", "SUP-003 Tabla de responsabilidades por proceso Scaling Up", "Dirección, Procesos, RH", 1250, 850, 450, 4, 4, 4],
      [4, 2, 4, "Formulario de fortalezas, debilidades y tendencias Scaling Up", "SUP-004 Formulario de fortalezas, debilidades y tendencias Scaling Up", "Dirección", 1250, 850, 450, 4, 4, 4],
      [4, 3, 1, "Detección de necesidades de capacitación", "OPE-037 Detección de necesidades de capacitación", "Integral", 1250, 850, 450, 2, 2, 2],
      [4, 3, 2, "Capacitación Mejora continua práctica (cómo mejorar paso a paso)", "OPE-038 Hoja de datos de capacitacion", "Procesos", 1250, 850, 450, 4, 12, 24],
      [4, 3, 3, "Capacitación Encontrar la causa real de los problemas (5 porqués / diagrama simple)", "OPE-038 Hoja de datos de capacitacion", "Procesos", 1250, 850, 450, 4, 12, 24],
      [4, 4, 1, "Capacitación Resolver problemas de forma ordenada (método A3/8D sencillo)", "OPE-038 Hoja de datos de capacitacion", "Procesos", 1250, 850, 450, 4, 12, 24],
      [4, 4, 2, "Capacitación Seguimiento de acciones correctivas (pendientes, responsables y verificación)", "OPE-038 Hoja de datos de capacitacion", "Procesos", 1250, 850, 450, 4, 12, 24],
      [4, 4, 3, "Actualizar validación de modelo de negocio (CANVA)", "OPE-010 Preguntas para modelo CANVAS", "Dirección, Procesos, Comercial", 1250, 850, 450, 4, 8, 12],
      [4, 5, 1, "Actualizar Alineación estratégica", "OPE-012 Guía de alineación estratégica", "Dirección, Procesos, Comercial", 1250, 850, 450, 4, 8, 12],
      [4, 5, 2, "Actualizar evaluación de dependencia del dueño", "OPE-013 Dependencia del dueño", "Dirección, Procesos", 1250, 850, 450, 2, 4, 8],
      [4, 5, 3, "Actualizar macroproceso, dueños de proceso y KPIs", "OPE-016 Base de datos macro proceso", "Procesos", 1250, 850, 450, 8, 12, 24],
      [4, 5, 4, "Auditorias y conciliaciones aleatorias (Identificar si hubo fugas de dinero)", "OPE-020 Conciliación / Paretto de gastos OPE-023", "Finanzas", 1250, 850, 450, 1, 4, 8],
      [4, 6, 1, "Análisis de flujo de efectivo (trimestre)", "OPE-022 Flujo de efectivo 13 semanas", "Finanzas", 1250, 850, 450, 1, 4, 8],
      [4, 6, 2, "Análisis de pendientes por cobrar, rentabilidad y margen", "OPE-023 Estado de resultados (3 meses)", "Finanzas", 1250, 850, 450, 1, 4, 8],
      [4, 6, 3, "Presentar dictamen financiero y acciones correctivas", "OPE-024 Dictamen financiero", "Finanzas", 1250, 850, 450, 2, 2, 2],
      [4, 6, 4, "Identificar segmentos y cliente ideal", "OPE-027 Formato de Identificación de segmentos y cliente ideal", "Comercial", 1250, 850, 450, 2, 2, 4],
      [4, 7, 1, "Estrategia comercial por segmento (1)", "OPE-028 Formato de estrategia comercial por segmento", "Comercial", 1250, 850, 450, 4, 8, 24],
      [4, 7, 2, "Estrategia comercial por segmento (2)", "OPE-028 Formato de estrategia comercial por segmento", "Comercial", 1250, 850, 450, 4, 8, 24],
      [4, 8, 1, "Estrategia comercial por segmento (3)", "OPE-028 Formato de estrategia comercial por segmento", "Comercial", 1250, 850, 450, 4, 8, 24],
      [4, 8, 2, "Auditoria a proveedores", "OPE-029 Formato de alta y evaluación de proveedores", "Procesos", 1250, 850, 450, 2, 4, 8],
      [4, 8, 3, "Auditoría a equipo de TI", "OPE-031 Carta responsiva de equipo de TI", "Procesos", 1250, 850, 450, 2, 4, 8],
      [4, 9, 1, "Actualizar perfiles de puesto (Área/ gerencia 1 y 2)", "OPE-032 Perfil de puestos", "Procesos, Comercial", 1250, 850, 450, 4, 8, 16],
      [4, 9, 2, "Actualizar perfiles de puesto (Área/ gerencia 3 ,4 y 5)", "OPE-032 Perfil de puestos", "Procesos, RH", 1250, 850, 450, 4, 8, 16],
      [4, 9, 3, "Actualizar organigrama", "OPE-033 Organigrama finalizado", "RH", 1250, 850, 450, 4, 8, 16],
      [4, 9, 4, "Actualizar matriz RACI", "OPE-034 Matriz de responsabilidades (RACI)", "Dirección, Procesos, RH", 1250, 850, 450, 4, 8, 16],
      [4, 10, 1, "Actualizar y mejorar contrato individual", "OPE-035 Contrato individual", "RH", 1250, 850, 450, 2, 4, 12],
      [4, 10, 2, "Actualizar y mejorar reglamento interno de trabajo", "OPE-036 Reglamento interno de trabajo", "RH", 1250, 850, 450, 2, 4, 12],
      [4, 10, 3, "Encuesta de clima organizacional", "OPE-043 Encuesta de clima organizacional", "RH", 1250, 850, 450, 2, 4, 12],
      [4, 11, 1, "Estandarización de procesos", "OPE-018 Documentación de procesos", "Dirección, Procesos", 1250, 850, 450, 4, 8, 16],
      [4, 11, 2, "Estandarización de procesos", "OPE-018 Documentación de procesos", "Dirección, Procesos", 1250, 850, 450, 4, 8, 16],
      [4, 11, 3, "Estandarización de procesos", "OPE-018 Documentación de procesos", "Dirección, Procesos", 1250, 850, 450, 4, 8, 16],
      [4, 11, 4, "Capacitación en procesos implementados", "OPE-038 Hoja de datos de capacitacion", "Dirección, Procesos", 1250, 850, 450, 4, 8, 16],
      [4, 12, 1, "Documentación de políticas", "OPE-019 Documentación de políticas", "Dirección, Procesos", 1250, 850, 450, 4, 8, 16],
      [4, 12, 2, "Documentación de políticas", "OPE-019 Documentación de políticas", "Dirección, Procesos", 1250, 850, 450, 4, 8, 16],
      [4, 12, 3, "Capacitación en políticas implementadas", "OPE-038 Hoja de datos de capacitacion", "Dirección", 1250, 850, 450, 4, 8, 16],
      [4, 12, 4, "Elaboración de plan a la medida (cronograma etapa 5)", "EST-003 Metodología Consilium", "Dirección", 1250, 850, 450, 1, 2, 2],
      [4, 12, 4, "Diagnóstico para membresía", "OPE-020 Diagnóstico para membresía", "Integral", 1250, 850, 450, 0, 0, 1],

      # --- ETAPA 5 (43 Tareas) ---
      [5, 1, 1, "Presentar plan de actividades de la etapa 4", "EST-003 Metodología Consilium", "Integral", 1250, 850, 450, 2, 2, 2],
      [5, 1, 2, "Enviar autodiagnóstico '5 áreas clave'", "OPE-003 Autodiagnóstico", "Integral", 1250, 850, 450, 1, 1, 1],
      [5, 1, 3, "Analizar resultado y elaborar dictamen", "OPE-008 Dictamen de hallazgos", "Integral", 1250, 850, 450, 2, 2, 8],
      [5, 1, 4, "Presentar Dictamen de autodiagnóstico", "OPE-008 Dictamen de hallazgos", "Integral", 1250, 850, 450, 2, 2, 2],
      [5, 2, 1, "Capacitación Scaling Up Fase 2", "OPE-038 Hoja de datos de capacitacion", "Integral", 1250, 850, 450, 4, 4, 4],
      [5, 2, 2, "Estratos Scaling UP", "SUP-005 Estratos Scaling UP", "Integral", 1250, 850, 450, 4, 4, 4],
      [5, 2, 3, "Plan estrategico de una pagina Scaling Up", "SUP-006 y SUP-007 Plan estrategico de una pagina Scaling Up", "Integral", 1250, 850, 450, 4, 4, 4],
      [5, 2, 4, "Resumen de Vision Scaling Up", "SUP-008 Resumen de Vision Scaling Up", "Integral", 1250, 850, 450, 4, 4, 4],
      [5, 3, 1, "Detección de necesidades de capacitación", "OPE-037 Detección de necesidades de capacitación", "Integral", 1250, 850, 450, 2, 2, 2],
      [5, 3, 2, "Cómo hacer la operación más eficiente", "OPE-038 Hoja de datos de capacitacion", "Integral", 1250, 850, 450, 4, 12, 24],
      [5, 3, 3, "Detectar y romper cuellos de botella", "OPE-038 Hoja de datos de capacitacion", "Integral", 1250, 850, 450, 4, 12, 24],
      [5, 4, 1, "Optimización del flujo de trabajo (recorridos, secuencias y layout)", "OPE-038 Hoja de datos de capacitacion", "Integral", 1250, 850, 450, 4, 12, 24],
      [5, 4, 2, "Estandarizar para crecer (misma forma de trabajar en todos los equipos/sedes)", "OPE-038 Hoja de datos de capacitacion", "Integral", 1250, 850, 450, 4, 12, 24],
      [5, 4, 3, "Actualizar validación de modelo de negocio (CANVA)", "OPE-010 Preguntas para modelo CANVAS", "Dirección, Procesos, Comercial", 1250, 850, 450, 4, 8, 12],
      [5, 5, 1, "Actualizar Alineación estratégica", "OPE-012 Guía de alineación estratégica", "Dirección, Procesos, Comercial", 1250, 850, 450, 4, 8, 12],
      [5, 5, 2, "Actualizar evaluación de dependencia del dueño", "OPE-013 Dependencia del dueño", "Dirección, Procesos", 1250, 850, 450, 2, 4, 8],
      [5, 5, 3, "Actualizar macroproceso, dueños de proceso y KPIs", "OPE-016 Base de datos macro proceso", "Procesos", 1250, 850, 450, 8, 12, 24],
      [5, 5, 4, "Auditorias y conciliaciones aleatorias (Identificar si hubo fugas de dinero)", "OPE-020 Conciliación / Paretto de gastos OPE-023", "Finanzas", 1250, 850, 450, 1, 4, 8],
      [5, 6, 1, "Análisis de flujo de efectivo (trimestre)", "OPE-022 Flujo de efectivo 13 semanas", "Finanzas", 1250, 850, 450, 1, 4, 8],
      [5, 6, 2, "Análisis de pendientes por cobrar, rentabilidad y margen", "OPE-023 Estado de resultados (3 meses)", "Finanzas", 1250, 850, 450, 1, 4, 8],
      [5, 6, 3, "Presentar dictamen financiero y acciones correctivas", "OPE-024 Dictamen financiero", "Finanzas", 1250, 850, 450, 2, 2, 2],
      [5, 6, 4, "Identificar segmentos y cliente ideal", "OPE-027 Formato de Identificación de segmentos y cliente ideal", "Comercial", 1250, 850, 450, 2, 2, 4],
      [5, 7, 1, "Estrategia comercial por segmento (1)", "OPE-028 Formato de estrategia comercial por segmento", "Comercial", 1250, 850, 450, 4, 8, 24],
      [5, 7, 2, "Estrategia comercial por segmento (2)", "OPE-028 Formato de estrategia comercial por segmento", "Comercial", 1250, 850, 450, 4, 8, 24],
      [5, 8, 1, "Estrategia comercial por segmento (3)", "OPE-028 Formato de estrategia comercial por segmento", "Comercial", 1250, 850, 450, 4, 8, 24],
      [5, 8, 2, "Auditoria a proveedores", "OPE-029 Formato de alta y evaluación de proveedores", "Procesos", 1250, 850, 450, 2, 4, 8],
      [5, 8, 3, "Auditoría a equipo de TI", "OPE-031 Carta responsiva de equipo de TI", "Procesos", 1250, 850, 450, 2, 4, 8],
      [5, 9, 1, "Actualizar perfiles de puesto (Área/ gerencia 1 y 2)", "OPE-032 Perfil de puestos", "Dirección, Finanzas", 1250, 850, 450, 4, 8, 16],
      [5, 9, 2, "Actualizar perfiles de puesto (Área/ gerencia 3 ,4 y 5)", "OPE-032 Perfil de puestos", "Procesos, Comercial, RH", 1250, 850, 450, 4, 8, 16],
      [5, 9, 3, "Actualizar organigrama", "OPE-033 Organigrama finalizado", "RH", 1250, 850, 450, 4, 8, 16],
      [5, 9, 4, "Actualizar matriz RACI", "OPE-034 Matriz de responsabilidades (RACI)", "Dirección, Procesos", 1250, 850, 450, 4, 8, 16],
      [5, 10, 1, "Actualizar y mejorar contrato individual", "OPE-035 Contrato individual", "RH", 1250, 850, 450, 2, 4, 12],
      [5, 10, 2, "Actualizar y mejorar reglamento interno de trabajo", "OPE-036 Reglamento interno de trabajo", "RH", 1250, 850, 450, 2, 4, 12],
      [5, 10, 3, "Encuesta de clima organizacional", "OPE-039 Hoja de requisitos de página web", "Dirección", 1250, 850, 450, 2, 4, 12],
      [5, 11, 1, "Estandarización de procesos", "OPE-018 Documentación de procesos", "Procesos", 1250, 850, 450, 4, 8, 16],
      [5, 11, 2, "Estandarización de procesos", "OPE-018 Documentación de procesos", "Comercial", 1250, 850, 450, 4, 8, 16],
      [5, 11, 3, "Estandarización de procesos", "OPE-018 Documentación de procesos", "RH", 1250, 850, 450, 4, 8, 16],
      [5, 11, 4, "Capacitación en procesos implementados", "OPE-038 Hoja de datos de capacitacion", "Comercial", 1250, 850, 450, 4, 8, 16],
      [5, 12, 1, "Documentación de politicas", "OPE-019 Documentación de políticas", "Comercial", 1250, 850, 450, 4, 8, 16],
      [5, 12, 2, "Documentación de politicas", "OPE-019 Documentación de políticas", "Comercial", 1250, 850, 450, 4, 8, 16],
      [5, 12, 3, "Capacitación en políticas implementadas", "OPE-038 Hoja de datos de capacitacion", "Dirección", 1250, 850, 450, 4, 8, 16],
      [5, 12, 4, "Elaboración de plan a la medida (cronograma etapa 5)", "EST-003 Metodología Consilium", "Dirección", 1250, 850, 450, 1, 2, 2],
      [5, 12, 4, "Diagnóstico para membresía", "OPE-020 Diagnóstico para membresía", "Integral", 1250, 850, 450, 0, 0, 1],

      # --- ETAPA 6 (43 Tareas) ---
      [6, 1, 1, "Presentar plan de actividades de la etapa 4", "EST-003 Metodología Consilium", "Integral", 1250, 850, 450, 2, 2, 2],
      [6, 1, 2, "Enviar autodiagnóstico '5 áreas clave'", "OPE-003 Autodiagnóstico", "Integral", 1250, 850, 450, 1, 1, 1],
      [6, 1, 3, "Analizar resultado y elaborar dictamen", "OPE-008 Dictamen de hallazgos", "Integral", 1250, 850, 450, 2, 2, 8],
      [6, 1, 4, "Presentar Dictamen de autodiagnóstico", "OPE-008 Dictamen de hallazgos", "Integral", 1250, 850, 450, 2, 2, 2],
      [6, 2, 1, "Ejecucion quien, que cuando Scaling Up", "SUP-009 Ejecucion quien, que cuando Scaling Up", "Integral", 1250, 850, 450, 4, 4, 4],
      [6, 2, 2, "Evaluacion de Los hábitos de Rockefeller", "SUP-010 Evaluacion de Los hábitos de Rockefeller", "Integral", 1250, 850, 450, 4, 4, 4],
      [6, 2, 3, "Estrategias de acelerecion de efectivo", "SUP-011 Estrategias de acelerecion de efectivo", "Integral", 1250, 850, 450, 4, 4, 4],
      [6, 2, 4, "El poder del uno Scaling Up", "SUP-012 El poder del uno Scaling Up", "Integral", 1250, 850, 450, 4, 4, 4],
      [6, 3, 1, "Detección de necesidades de capacitación", "OPE-037 Detección de necesidades de capacitación", "Integral", 1250, 850, 450, 2, 2, 2],
      [6, 3, 2, "Reglas claras de operación y toma de decisiones (gobernanza)", "OPE-038 Hoja de datos de capacitacion", "Integral", 1250, 850, 450, 4, 12, 24],
      [6, 3, 3, "Delegación y continuidad (manuales y plan de reemplazos)", "OPE-038 Hoja de datos de capacitacion", "Integral", 1250, 850, 450, 4, 12, 24],
      [6, 4, 1, "Prevenir riesgos y errores repetitivos (controles internos simples)", "OPE-038 Hoja de datos de capacitacion", "Integral", 1250, 850, 450, 4, 12, 24],
      [6, 4, 2, "Gestión de proyectos y mejoras (prioridades y resultados)", "OPE-038 Hoja de datos de capacitacion", "Integral", 1250, 850, 450, 4, 12, 24],
      [6, 4, 3, "Actualizar validación de modelo de negocio (CANVA)", "OPE-010 Preguntas para modelo CANVAS", "Dirección, Procesos, Comercial", 1250, 850, 450, 4, 8, 12],
      [6, 5, 1, "Actualizar Alineación estratégica", "OPE-012 Guía de alineación estratégica", "Dirección, Procesos, Comercial", 1250, 850, 450, 4, 8, 12],
      [6, 5, 2, "Actualizar evaluación de dependencia del dueño", "OPE-013 Dependencia del dueño", "Dirección, Procesos", 1250, 850, 450, 2, 4, 8],
      [6, 5, 3, "Actualizar macroproceso, dueños de proceso y KPIs", "OPE-016 Base de datos macro proceso", "Procesos", 1250, 850, 450, 8, 12, 24],
      [6, 5, 4, "Auditorias y conciliaciones aleatorias (Identificar si hubo fugas de dinero)", "OPE-020 Conciliación / Paretto de gastos OPE-023", "Finanzas", 1250, 850, 450, 1, 4, 8],
      [6, 6, 1, "Análisis de flujo de efectivo (trimestre)", "OPE-022 Flujo de efectivo 13 semanas", "Finanzas", 1250, 850, 450, 1, 4, 8],
      [6, 6, 2, "Análisis de pendientes por cobrar, rentabilidad y margen", "OPE-023 Estado de resultados (3 meses)", "Finanzas", 1250, 850, 450, 1, 4, 8],
      [6, 6, 3, "Presentar dictamen financiero y acciones correctivas", "OPE-024 Dictamen financiero", "Finanzas", 1250, 850, 450, 2, 2, 2],
      [6, 6, 4, "Identificar segmentos y cliente ideal", "OPE-027 Formato de Identificación de segmentos y cliente ideal", "Comercial", 1250, 850, 450, 2, 2, 4],
      [6, 7, 1, "Estrategia comercial por segmento (1)", "OPE-028 Formato de estrategia comercial por segmento", "Comercial", 1250, 850, 450, 4, 8, 24],
      [6, 7, 2, "Estrategia comercial por segmento (2)", "OPE-028 Formato de estrategia comercial por segmento", "Comercial", 1250, 850, 450, 4, 8, 24],
      [6, 8, 1, "Estrategia comercial por segmento (3)", "OPE-028 Formato de estrategia comercial por segmento", "Comercial", 1250, 850, 450, 4, 8, 24],
      [6, 8, 2, "Auditoria a proveedores", "OPE-029 Formato de alta y evaluación de proveedores", "Procesos", 1250, 850, 450, 2, 4, 8],
      [6, 8, 3, "Auditoría a equipo de TI", "OPE-031 Carta responsiva de equipo de TI", "Procesos", 1250, 850, 450, 2, 4, 8],
      [6, 9, 1, "Actualizar perfiles de puesto (Área/ gerencia 1 y 2)", "OPE-032 Perfil de puestos", "Dirección, Finanzas", 1250, 850, 450, 4, 8, 16],
      [6, 9, 2, "Actualizar perfiles de puesto (Área/ gerencia 3 ,4 y 5)", "OPE-032 Perfil de puestos", "Procesos, Comercial, RH", 1250, 850, 450, 4, 8, 16],
      [6, 9, 3, "Actualizar organigrama", "OPE-033 Organigrama finalizado", "RH", 1250, 850, 450, 4, 8, 16],
      [6, 9, 4, "Actualizar matriz RACI", "OPE-034 Matriz de responsabilidades (RACI)", "Dirección, Procesos", 1250, 850, 450, 4, 8, 16],
      [6, 10, 1, "Actualizar y mejorar contrato individual", "OPE-035 Contrato individual", "RH", 1250, 850, 450, 2, 4, 12],
      [6, 10, 2, "Actualizar y mejorar reglamento interno de trabajo", "OPE-036 Reglamento interno de trabajo", "RH", 1250, 850, 450, 2, 4, 12],
      [6, 10, 3, "Encuesta de clima organizacional", "OPE-039 Hoja de requisitos de página web", "Dirección", 1250, 850, 450, 2, 4, 12],
      [6, 11, 1, "Estandarización de procesos", "OPE-018 Documentación de procesos", "Procesos", 1250, 850, 450, 4, 8, 16],
      [6, 11, 2, "Estandarización de procesos", "OPE-018 Documentación de procesos", "Comercial", 1250, 850, 450, 4, 8, 16],
      [6, 11, 3, "Estandarización de procesos", "OPE-018 Documentación de procesos", "RH", 1250, 850, 450, 4, 8, 16],
      [6, 11, 4, "Capacitación en procesos implementados", "OPE-038 Hoja de datos de capacitacion", "Comercial", 1250, 850, 450, 4, 8, 16],
      [6, 12, 1, "Documentación de politicas", "OPE-019 Documentación de políticas", "Comercial", 1250, 850, 450, 4, 8, 16],
      [6, 12, 2, "Documentación de politicas", "OPE-019 Documentación de políticas", "Comercial", 1250, 850, 450, 4, 8, 16],
      [6, 12, 3, "Capacitación en políticas implementadas", "OPE-038 Hoja de datos de capacitacion", "Dirección", 1250, 850, 450, 4, 8, 16],
      [6, 12, 4, "Elaboración de plan a la medida (cronograma etapa 5)", "EST-003 Metodología Consilium", "Dirección", 1250, 850, 450, 1, 2, 2],
      [6, 12, 4, "Diagnóstico para membresía", "OPE-020 Diagnóstico para membresía", "Integral", 1250, 850, 450, 0, 0, 1]
    ]

    # 3. Motor de Inserción
    actividades_creadas = 0

    actividades.each do |row|
      stage_num = row[0]
      mes       = row[1]
      semana    = row[2]
      nombre    = row[3]
      doc_ref   = row[4]
      areas_raw = row[5] # Ej: "Dirección, Procesos, Comercial"
      
      # 🛠️ FIX DE VALIDACIÓN: Tomamos solo la primera área de la cadena
      # "Dirección, Procesos, Comercial" -> se convierte en "Dirección"
      area_principal = areas_raw.split(',').first.to_s.strip
      
      tar_l = row[6].to_f
      tar_s = row[7].to_f
      tar_a = row[8].to_f
      
      hrs_l = row[9].to_f
      hrs_s = row[10].to_f
      hrs_a = row[11].to_f

      # Cálculo de costo matemático infalible
      costo_calc = (tar_l * hrs_l) + (tar_s * hrs_s) + (tar_a * hrs_a)

      target_stage = stages_hash[stage_num]

      if target_stage
        target_stage.activities.create!(
          name: nombre,
          month: mes,
          week: semana,
          document_ref: doc_ref,
          area: area_principal, # <-- Enviamos solo el área principal validada
          activity_cost: costo_calc,
          leader_rate: tar_l,
          senior_rate: tar_s,
          analyst_rate: tar_a,
          leader_hours: hrs_l,
          senior_hours: hrs_s,
          analyst_hours: hrs_a,
          user_id: user.id,
          responsible_id: user.id,
          status: 'pending',
          completed: false
        )
        actividades_creadas += 1
      end
    end

    Rails.logger.info "✅ Template GOLD completado exitosamente: #{actividades_creadas} actividades insertadas en milisegundos."
  end
end