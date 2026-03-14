module ProjectTemplates
  module Y2023
    class BasicaService
      def self.generate(project, user)
        stages_definitions = [
          "Etapa 1 - Alinear y Diagnosticar",
          "Etapa 2 - Ordenar y Controlar",
          "Etapa 3 - Estandarizar y Profesionalizar",
          "Etapa 4 - Mejora Continua y Consolidación",
          "Etapa 5 - Optimización y Escalamiento"
        ]

        stages_hash = {}
        stages_definitions.each_with_index do |name, i|
          stages_hash[i + 1] = project.stages.find_or_create_by!(position: i + 1, name: name)
        end

        actividades = [
          # --- ETAPA 1 (24 Tareas) ---
          [1, 1, 1, "Diagnóstico para membresía", "OPE-020 Diagnóstico para membresía", "Integral", 1250, 850, 450, 0.5, 0, 0, "2023-01-10"],
          [1, 1, 1, "Solicitar y revisar expediente", "OPE-001 Check list de expediente inicial", "Integral", 1250, 850, 450, 1, 1, 1, "2023-01-10"],
          [1, 1, 1, "Realizar la ficha de datos básicos del cliente", "OPE-002 Ficha de datos del cliente", "Integral", 1250, 850, 450, 1, 0.5, 1, "2023-01-13"],
          [1, 1, 2, "Enviar autodiagnóstico \"5 áreas clave\"", "OPE-003 Autodiagnóstico", "Integral", 1250, 850, 450, 1, 0.5, 1, "2023-01-13"],
          [1, 1, 2, "Elaboración de dictamen de hallazgos según respuestas de autodiagnóstico", "OPE-008 Dictamen autodiagnóstico", "Integral", 1250, 850, 450, 1, 0.5, 3, "2023-01-13"],
          [1, 1, 2, "Kick off con dueño y líderes clave", "EST-003 Metodología Consilium", "Integral", 1250, 850, 450, 1, 1, 1, "2023-01-17"],
          [1, 1, 2, "Presentación al cliente plan de trabajo etapa 1", "OPE-004 Bitácora de inicio Kick off", "Integral", 1250, 850, 450, 0.5, 0.5, 0.5, "2023-01-17"],
          [1, 1, 2, "Evaluación de contexto de la empresa", "OPE-006 Preguntas contexto", "Integral", 1250, 850, 450, 0.5, 0.5, 0.5, "2023-01-17"],
          [1, 1, 3, "Presentación de dictamen inicial de hallazgos", "OPE-008 Dictamen de hallazgos", "Integral", 1250, 850, 450, 1, 0.5, 1.5, "2023-01-17"],
          [1, 1, 3, "Solicitar documentos clave", "OPE-009 Lista consolidada de información solicitada", "Integral, Procesos, Comercial", 1250, 850, 450, 1, 1, 0, "2023-01-17"],
          [1, 1, 4, "Sesión de validación de modelo de negocio", "OPE-010 Preguntas para modelo CANVAS", "Dirección, Procesos, Comercial", 1250, 850, 450, 0.5, 2, 2, "2023-01-24"],
          [1, 1, 4, "Análisis y elaboración de modelo de negocio (CANVAS)", "OPE-010 Preguntas para modelo CANVAS / OPE-044 Modelo CANVAS", "Dirección, Procesos, Comercial", 1250, 850, 450, 1, 1, 1, "2023-01-24"],
          [1, 2, 1, "Presentación de modelo de negocio", "OPE-044 Modelo CANVAS / OPE-011 Minuta de reunión", "Dirección", 1250, 850, 450, 1, 1, 1, "2023-01-31"],
          [1, 2, 1, "Sesión de solicitud de información para Alineación estratégica", "OPE-012 Guía de alineación estratégica", "Dirección", 1250, 850, 450, 1, 2, 2, "2023-02-07"],
          [1, 2, 1, "Análisis y elaboración de modelo de alineación estratégica", "OPE-012 Guía de alineación estratégica", "Dirección", 1250, 850, 450, 1, 1, 1, "2023-02-07"],
          [1, 2, 2, "Presentación de Alineación estratégica", "OPE-011 Minuta de reunión", "Dirección", 1250, 850, 450, 1, 1, 1, "2023-02-14"],
          [1, 2, 2, "Sesión de validación de dependencia del dueño", "OPE-014 Dependencia del dueño", "Dirección", 1250, 850, 450, 2, 2, 2, "2023-02-21"],
          [1, 2, 2, "Análisis y elaboración de propuestas de acciones correctivas", "OPE-014 Dependencia del dueño", "Dirección", 1250, 850, 450, 1, 1, 0, "2023-02-21"],
          [1, 3, 3, "Presentación de resultados de dependencia del dueño", "OPE-011 Minuta de reunión", "Procesos", 1250, 850, 450, 2, 2, 2, "2023-02-28"],
          [1, 3, 3, "Sesión de solicitud de información para elaboración de macroproceso y KPIs", "OPE-016 Base de datos macro proceso", "Procesos", 1250, 850, 450, 1, 4, 4, "2023-03-07"],
          [1, 3, 4, "Análisis y elaboración de macro proceso y KPIs", "OPE-016 Base de datos macro proceso", "Procesos", 1250, 850, 450, 1, 1, 1, "2023-03-07"],
          [1, 3, 4, "Presentación de macroproceso e indicadores clave", "OPE-011 Minuta de reunión", "RH", 1250, 850, 450, 0, 0, 1, "2023-03-14"],
          [1, 3, 4, "Encuesta de clima organizacional", "OPE-043 Encuesta de clima organizacional", "Integral", 1250, 850, 450, 1, 1, 1, "2023-03-22"],
          [1, 3, 4, "Elaboración de plan a la medida (cronograma etapa 2)", "EST-003 Metodología Consilium", "Integral", 1250, 850, 450, 1, 1, 1, "2023-03-28"],

          # --- ETAPA 2 (30 Tareas) ---
          [2, 1, 1, "Presentar plan de actividades de la etapa 2", "EST-003 Metodología Consilium", "Integral", 1250, 850, 450, 1, 1, 0, "2023-04-04"],
          [2, 1, 1, "Elaborar un sistema de gestión y seguimiento a KPIs principales", "OPE-017 Sistema de seguimiento a KPIs (Macroproceso)", "Integral", 1250, 850, 450, 2, 4, 8, "2023-04-11"],
          [2, 1, 2, "Presentar y acordar periodicidad de seguimiento a KPIs principales", "OPE-017 Sistema de seguimiento a KPIs (Macroproceso)", "Integral", 1250, 850, 450, 2, 2, 0, "2023-04-18"],
          [2, 1, 3, "Documentar y mapear procesos prioritarios", "OPE-018 Documentación de procesos", "Procesos", 1250, 850, 450, 4, 6, 12, "2023-04-25"],
          [2, 1, 4, "Capacitación en procesos implementados", "OPE-038 Hoja de datos de capacitación", "Procesos", 1250, 850, 450, 4, 6, 12, "2023-05-02"],
          [2, 2, 1, "Documentar políticas prioritarias", "OPE-019 Documentación de políticas", "Procesos", 1250, 850, 450, 1, 4, 4, "2023-05-09"],
          [2, 2, 2, "Capacitación en políticas documentadas", "OPE-038 Hoja de datos de capacitación", "Procesos", 1250, 850, 450, 1, 4, 4, "2023-05-23"],
          [2, 2, 3, "Matriz de responsabilidades (RACI)", "OPE-034 Matriz de responsabilidades (RACI)", "RH", 1250, 850, 450, 1, 4, 4, "2023-06-06"],
          [2, 2, 4, "Organigrama", "Organigrama", "RH", 1250, 850, 450, 1, 1, 0, "2023-06-13"],
          [2, 3, 1, "Capacitación y comunicación de matriz de responsabilidades", "OPE-038 Hoja de datos de capacitación", "RH", 1250, 850, 450, 2, 4, 8, "2023-06-20"],
          [2, 3, 2, "Detección de necesidades de capacitación", "OPE-037 Detección de necesidades de capacitación", "Procesos", 1250, 850, 450, 1, 1, 1, "2023-06-27"],
          [2, 3, 3, "Capacitación Cómo trabajar por procesos", "OPE-038 Hoja de datos de capacitación", "Procesos", 1250, 850, 450, 2, 6, 12, "2023-07-04"],
          [2, 4, 4, "Capacitación Mapa general de procesos y responsables", "OPE-038 Hoja de datos de capacitación", "Procesos", 1250, 850, 450, 2, 6, 12, "2023-07-11"],
          [2, 4, 4, "Capacitación Indicadores clave por proceso", "OPE-038 Hoja de datos de capacitación", "Procesos", 1250, 850, 450, 2, 6, 12, "2023-07-18"],
          [2, 5, 1, "Capacitación Juntas de seguimiento efectivas", "OPE-038 Hoja de datos de capacitación", "Comercial", 1250, 850, 450, 2, 4, 8, "2023-07-25"],
          [2, 5, 2, "Identificación de segmentos y cliente ideal", "OPE-027 Formato de Identificación de segmentos", "Comercial", 1250, 850, 450, 2, 6, 12, "2023-08-01"],
          [2, 6, 1, "Estrategia comercial por segmento (1)", "OPE-028 Formato de estrategia comercial", "Comercial", 1250, 850, 450, 2, 6, 12, "2023-08-15"],
          [2, 6, 2, "Estrategia comercial por segmento (2)", "OPE-028 Formato de estrategia comercial", "Comercial", 1250, 850, 450, 2, 6, 12, "2023-09-05"],
          [2, 7, 1, "Estrategia comercial por segmento (3)", "OPE-028 Formato de estrategia comercial", "Procesos", 1250, 850, 450, 0, 2, 6, "2023-09-19"],
          [2, 7, 2, "Alta y evaluación de proveedores", "OPE-029 Formato de alta y evaluación", "Procesos", 1250, 850, 450, 1, 2, 6, "2023-10-03"],
          [2, 8, 1, "Contrato con proveedores", "OPE-030 Formato de contrato", "Procesos, RH", 1250, 850, 450, 0.5, 1, 6, "2023-10-17"],
          [2, 8, 2, "Carta responsiva de equipo de TI", "OPE-031 Carta responsiva de equipo de TI", "Dirección", 1250, 850, 450, 0.5, 1, 4, "2023-11-07"],
          [2, 8, 3, "Perfil de puestos (Área/Gerencia 1)", "OPE-032 Perfil de puestos", "Finanzas", 1250, 850, 450, 0.5, 1, 4, "2023-11-14"],
          [2, 8, 4, "Perfil de puestos (Área/Gerencia 2)", "OPE-032 Perfil de puestos", "Procesos", 1250, 850, 450, 0.5, 1, 4, "2023-11-21"],
          [2, 9, 1, "Perfil de puestos (Área/Gerencia 3)", "OPE-032 Perfil de puestos", "Comercial", 1250, 850, 450, 0.5, 1, 4, "2023-11-28"],
          [2, 9, 2, "Perfil de puestos (Área/Gerencia 4)", "OPE-032 Perfil de puestos", "RH", 1250, 850, 450, 0.5, 1, 4, "2023-12-05"],
          [2, 9, 3, "Perfil de puestos (Área/Gerencia 5)", "OPE-032 Perfil de puestos", "RH", 1250, 850, 450, 1, 2, 8, "2023-12-12"],
          [2, 9, 4, "Matriz de gestión de empleados", "OPE-041 Matriz de gestión de empleados", "Integral", 1250, 850, 450, 0.5, 1, 1, "2023-12-19"],
          [2, 9, 4, "Diagnóstico para membresía", "OPE-020 Diagnóstico para membresía", "Dirección", 1250, 850, 450, 0.5, 1, 1, "2023-12-28"],
          [2, 9, 4, "Elaboración de plan a la medida (cronograma etapa 3)", "EST-003 Metodología Consilium", "Integral", 1250, 850, 450, 0.5, 1, 1, "2023-12-28"],

          # --- ETAPA 3 (32 Tareas) ---
          [3, 1, 1, "Presentar plan de actividades de la etapa 3", "EST-003 Metodología Consilium", "Integral", 1250, 850, 450, 1, 1, 1, "2024-01-09"],
          [3, 1, 2, "Matriz de responsabilidades (RACI)", "OPE-034 Matriz de responsabilidades (RACI)", "Integral", 1250, 850, 450, 0.5, 2, 6, "2024-01-16"],
          [3, 1, 3, "Actualizar y mejorar contrato individual", "OPE-035 Contrato individual", "RH", 1250, 850, 450, 1, 1, 4, "2024-01-23"],
          [3, 1, 4, "Actualizar y mejorar reglamento interno de trabajo", "OPE-036 Reglamento interno de trabajo", "RH", 1250, 850, 450, 1, 1, 4, "2024-01-30"],
          [3, 2, 1, "Detección de necesidades de capacitación", "OPE-037 Detección de necesidades", "Integral", 1250, 850, 450, 1, 1, 3, "2024-02-06"],
          [3, 2, 2, "Capacitación cómo estandarizar la forma de trabajar", "OPE-038 Hoja de datos de capacitación", "Procesos", 1250, 850, 450, 1, 1, 3, "2024-02-13"],
          [3, 2, 3, "Capacitación cómo hacer procedimientos simples", "OPE-038 Hoja de datos de capacitación", "Procesos", 1250, 850, 450, 1, 1, 3, "2024-02-20"],
          [3, 2, 4, "Capacitación cómo usar checklists para asegurar calidad", "OPE-038 Hoja de datos de capacitación", "Procesos", 1250, 850, 450, 1, 1, 3, "2024-02-27"],
          [3, 3, 1, "Capacitación control de documentos y formatos", "OPE-038 Hoja de datos de capacitación", "Procesos", 1250, 850, 450, 1, 1, 3, "2024-03-05"],
          [3, 3, 2, "Capacitación Scaling Up Fase 1", "OPE-038 Hoja de datos de capacitación", "Dirección", 1250, 850, 450, 2, 2, 2, "2024-03-12"],
          [3, 3, 3, "Plan Personal de una pagina Scaling Up", "SUP-001 Plan Personal", "Dirección", 1250, 850, 450, 2, 2, 2, "2024-03-19"],
          [3, 3, 4, "Tabla de responsabilidades por función Scaling Up", "SUP-002 Tabla de responsabilidades", "Dirección, Procesos, RH", 1250, 850, 450, 2, 2, 2, "2024-03-26"],
          [3, 4, 1, "Tabla de responsabilidades por proceso Scaling Up", "SUP-003 Tabla de responsabilidades", "Dirección, Procesos, RH", 1250, 850, 450, 2, 2, 2, "2024-03-02"],
          [3, 4, 2, "Formulario de fortalezas, debilidades y tendencias", "SUP-004 Formulario de fortalezas", "Dirección", 1250, 850, 450, 1, 1, 3, "2024-03-09"],
          [3, 5, 3, "Documentación de políticas", "OPE-019 Documentación de políticas", "Dirección, Procesos", 1250, 850, 450, 2, 4, 12, "2024-03-16"],
          [3, 5, 3, "Documentación de políticas (continuación)", "OPE-019 Documentación de políticas", "Dirección, Procesos", 1250, 850, 450, 2, 4, 12, "2024-05-07"],
          [3, 5, 4, "Capacitación en políticas documentadas", "OPE-038 Hoja de datos de capacitación", "Dirección, Procesos", 1250, 850, 450, 2, 4, 12, "2024-05-21"],
          [3, 6, 1, "Estandarización de procesos", "OPE-018 Documentación de procesos", "Dirección, Procesos", 1250, 850, 450, 2, 4, 12, "2024-06-04"],
          [3, 6, 2, "Estandarización de procesos (continuación)", "OPE-018 Documentación de procesos", "Dirección, Procesos", 1250, 850, 450, 2, 4, 12, "2024-06-18"],
          [3, 7, 1, "Estandarización de procesos (continuación)", "OPE-018 Documentación de procesos", "Dirección, Procesos", 1250, 850, 450, 1, 2, 6, "2024-07-02"],
          [3, 7, 2, "Capacitación en procesos implementados", "OPE-038 Hoja de datos de capacitación", "Dirección, Procesos", 1250, 850, 450, 1, 6, 24, "2024-07-23"],
          [3, 8, 1, "Capacitación Scaling Up Fase 2", "OPE-038 Hoja de datos de capacitación", "Dirección", 1250, 850, 450, 4, 4, 4, "2024-08-06"],
          [3, 8, 2, "Estratos Scaling UP", "SUP-005 Estratos Scaling UP", "Dirección", 1250, 850, 450, 2, 2, 2, "2024-08-20"],
          [3, 9, 1, "Plan estratégico de una pagina Scaling Up", "SUP-006 y SUP-007", "Dirección, Comercial", 1250, 850, 450, 2, 2, 2, "2024-09-03"],
          [3, 9, 2, "Resumen de Visión Scaling Up", "SUP-008 Resumen de Visión", "Dirección", 1250, 850, 450, 2, 2, 2, "2024-09-17"],
          [3, 10, 1, "Ejecución quien, que cuando Scaling Up", "SUP-009", "Dirección, RH", 1250, 850, 450, 2, 2, 2, "2024-10-01"],
          [3, 10, 2, "Evaluación de Los hábitos de Rockefeller", "SUP-010", "Finanzas", 1250, 850, 450, 2, 2, 2, "2024-10-15"],
          [3, 11, 1, "Estrategias de aceleración de efectivo", "SUP-011", "Finanzas", 1250, 850, 450, 2, 2, 2, "2024-11-05"],
          [3, 11, 2, "El poder del uno Scaling Up", "SUP-012", "Finanzas", 1250, 850, 450, 2, 2, 2, "2024-11-19"],
          [3, 12, 1, "Retroalimentación de Scaling Up", "OPE-041 Hoja de datos de capacitación", "Integral", 1250, 850, 450, 2, 6, 24, "2024-12-03"],
          [3, 12, 2, "Elaboración de plan a la medida", "EST-003 Metodología Consilium", "Integral", 1250, 850, 450, 0.5, 1, 1, "2024-12-17"],
          [3, 12, 3, "Diagnóstico para membresía", "OPE-020 Diagnóstico", "Integral", 1250, 850, 450, 0.5, 1, 1, "2024-12-17"],

          # --- ETAPA 4 (43 Tareas) ---
          [4, 1, 1, "Presentar plan de actividades de la etapa 4", "EST-003 Metodología Consilium", "Integral", 1250, 850, 450, 1, 1, 1, "2025-01-07"],
          [4, 1, 2, "Enviar autodiagnóstico \"5 áreas clave\"", "OPE-003 Autodiagnóstico", "Integral", 1250, 850, 450, 0.5, 0.5, 0.5, "2025-01-14"],
          [4, 1, 3, "Analizar resultado y elaborar dictamen", "OPE-008 Dictamen de hallazgos", "Integral", 1250, 850, 450, 1, 1, 4, "2025-01-21"],
          [4, 1, 4, "Presentar Dictamen de autodiagnóstico", "OPE-008 Dictamen de hallazgos", "Integral", 1250, 850, 450, 1, 1, 1, "2025-01-28"],
          [4, 2, 1, "Plan Personal de una pagina Scaling Up", "SUP-001 Plan Personal", "Dirección", 1250, 850, 450, 2, 2, 2, "2025-02-04"],
          [4, 2, 2, "Tabla de responsabilidades por función Scaling Up", "SUP-002 Tabla de responsabilidades", "Dirección, Procesos, RH", 1250, 850, 450, 2, 2, 2, "2025-02-11"],
          [4, 2, 3, "Tabla de responsabilidades por proceso Scaling Up", "SUP-003 Tabla de responsabilidades", "Dirección, Procesos, RH", 1250, 850, 450, 2, 2, 2, "2025-02-18"],
          [4, 2, 4, "Formulario de fortalezas, debilidades y tendencias Scaling Up", "SUP-004 Formulario de fortalezas", "Dirección", 1250, 850, 450, 2, 2, 2, "2025-02-25"],
          [4, 3, 1, "Detección de necesidades de capacitación", "OPE-037 Detección de necesidades", "Integral", 1250, 850, 450, 1, 1, 1, "2025-03-04"],
          [4, 3, 2, "Capacitación Mejora continua práctica", "OPE-038 Hoja de datos de capacitacion", "Procesos", 1250, 850, 450, 2, 6, 12, "2025-03-11"],
          [4, 3, 3, "Capacitación Encontrar la causa real de los problemas", "OPE-038 Hoja de datos de capacitacion", "Procesos", 1250, 850, 450, 2, 6, 12, "2025-03-18"],
          [4, 4, 1, "Capacitación Resolver problemas de forma ordenada", "OPE-038 Hoja de datos de capacitacion", "Procesos", 1250, 850, 450, 2, 6, 12, "2025-04-08"],
          [4, 4, 2, "Capacitación Seguimiento de acciones correctivas", "OPE-038 Hoja de datos de capacitacion", "Procesos", 1250, 850, 450, 2, 6, 12, "2025-04-15"],
          [4, 4, 3, "Actualizar validación de modelo de negocio (CANVA)", "OPE-010 Preguntas para modelo CANVAS", "Dirección, Procesos, Comercial", 1250, 850, 450, 2, 4, 6, "2025-04-22"],
          [4, 5, 1, "Actualizar Alineación estratégica", "OPE-012 Guía de alineación estratégica", "Dirección, Procesos, Comercial", 1250, 850, 450, 2, 4, 6, "2025-05-06"],
          [4, 5, 2, "Actualizar evaluación de dependencia del dueño", "OPE-013 Dependencia del dueño", "Dirección, Procesos", 1250, 850, 450, 1, 2, 4, "2025-05-13"],
          [4, 5, 3, "Actualizar macroproceso, dueños de proceso y KPIs", "OPE-016 Base de datos macro proceso", "Procesos", 1250, 850, 450, 4, 6, 12, "2025-05-20"],
          [4, 5, 4, "Auditorias y conciliaciones aleatorias", "OPE-020 Conciliación / Paretto", "Finanzas", 1250, 850, 450, 0.5, 2, 4, "2025-05-27"],
          [4, 6, 1, "Análisis de flujo de efectivo (trimestre)", "OPE-022 Flujo de efectivo", "Finanzas", 1250, 850, 450, 0.5, 2, 4, "2025-06-03"],
          [4, 6, 2, "Análisis de pendientes por cobrar, rentabilidad y margen", "OPE-023 Estado de resultados", "Finanzas", 1250, 850, 450, 0.5, 2, 4, "2025-06-10"],
          [4, 6, 3, "Presentar dictamen financiero y acciones correctivas", "OPE-024 Dictamen financiero", "Finanzas", 1250, 850, 450, 1, 1, 0, "2025-06-17"],
          [4, 6, 4, "Identificar segmentos y cliente ideal", "OPE-027 Formato de Identificación", "Comercial", 1250, 850, 450, 1, 1, 2, "2025-06-24"],
          [4, 7, 1, "Estrategia comercial por segmento (1)", "OPE-028 Formato de estrategia", "Comercial", 1250, 850, 450, 2, 4, 12, "2025-07-01"],
          [4, 7, 2, "Estrategia comercial por segmento (2)", "OPE-028 Formato de estrategia", "Comercial", 1250, 850, 450, 2, 4, 12, "2025-07-15"],
          [4, 8, 1, "Estrategia comercial por segmento (3)", "OPE-028 Formato de estrategia", "Comercial", 1250, 850, 450, 2, 4, 12, "2025-08-05"],
          [4, 8, 2, "Auditoria a proveedores", "OPE-029 Formato de alta", "Procesos", 1250, 850, 450, 0, 2, 4, "2025-08-19"],
          [4, 8, 3, "Auditoría a equipo de TI", "OPE-031 Carta responsiva", "Procesos", 1250, 850, 450, 0, 2, 4, "2025-08-26"],
          [4, 9, 1, "Actualizar perfiles de puesto (Área/ gerencia 1 y 2)", "OPE-032 Perfil de puestos", "Procesos, Comercial", 1250, 850, 450, 2, 4, 8, "2025-09-02"],
          [4, 9, 2, "Actualizar perfiles de puesto (Área/ gerencia 3 ,4 y 5)", "OPE-032 Perfil de puestos", "Procesos, Comercial, RH", 1250, 850, 450, 2, 4, 8, "2025-09-09"],
          [4, 9, 3, "Actualizar organigrama", "OPE-033 Organigrama finalizado", "RH", 1250, 850, 450, 2, 4, 8, "2025-09-17"],
          [4, 9, 4, "Actualizar matriz RACI", "OPE-034 Matriz de responsabilidades", "Dirección, Procesos, RH", 1250, 850, 450, 2, 4, 8, "2025-09-23"],
          [4, 10, 1, "Actualizar y mejorar contrato individual", "OPE-035 Contrato individual", "RH", 1250, 850, 450, 1, 2, 6, "2025-10-07"],
          [4, 10, 2, "Actualizar y mejorar reglamento interno de trabajo", "OPE-036 Reglamento interno", "RH", 1250, 850, 450, 1, 2, 6, "2025-10-14"],
          [4, 10, 3, "Encuesta de clima organizacional", "OPE-043 Encuesta de clima", "RH", 1250, 850, 450, 1, 2, 6, "2025-10-21"],
          [4, 11, 1, "Estandarización de procesos", "OPE-018 Documentación de procesos", "Dirección, Procesos", 1250, 850, 450, 2, 4, 8, "2025-11-04"],
          [4, 11, 2, "Estandarización de procesos", "OPE-018 Documentación de procesos", "Dirección, Procesos", 1250, 850, 450, 2, 4, 8, "2025-11-11"],
          [4, 11, 3, "Estandarización de procesos", "OPE-018 Documentación de procesos", "Dirección, Procesos", 1250, 850, 450, 2, 4, 8, "2025-11-18"],
          [4, 11, 4, "Capacitación en procesos implementados", "OPE-038 Hoja de datos", "Dirección, Procesos", 1250, 850, 450, 2, 4, 8, "2025-11-25"],
          [4, 12, 1, "Documentación de políticas", "OPE-019 Documentación de políticas", "Dirección, Procesos", 1250, 850, 450, 2, 4, 8, "2025-12-02"],
          [4, 12, 2, "Documentación de políticas", "OPE-019 Documentación de políticas", "Dirección, Procesos", 1250, 850, 450, 2, 4, 8, "2025-12-09"],
          [4, 12, 3, "Capacitación en políticas implementadas", "OPE-038 Hoja de datos", "Dirección", 1250, 850, 450, 2, 4, 8, "2025-12-16"],
          [4, 12, 4, "Elaboración de plan a la medida", "EST-003 Metodología Consilium", "Dirección", 1250, 850, 450, 0.5, 1, 1, "2025-12-23"],
          [4, 12, 4, "Diagnóstico para membresía", "OPE-020 Diagnóstico", "Integral", 1250, 850, 450, 0.5, 1, 1, "2025-12-23"],

          # --- ETAPA 5 (43 Tareas) ---
          [5, 1, 1, "Presentar plan de actividades", "EST-003 Metodología Consilium", "Integral", 1250, 850, 450, 1, 1, 1, "2026-01-07"],
          [5, 1, 2, "Enviar autodiagnóstico \"5 áreas clave\"", "OPE-003 Autodiagnóstico", "Integral", 1250, 850, 450, 0.5, 0.5, 0.5, "2026-01-13"],
          [5, 1, 3, "Analizar resultado y elaborar dictamen", "OPE-008 Dictamen de hallazgos", "Integral", 1250, 850, 450, 1, 1, 4, "2026-01-20"],
          [5, 1, 4, "Presentar Dictamen de autodiagnóstico", "OPE-008 Dictamen de hallazgos", "Integral", 1250, 850, 450, 1, 1, 1, "2026-01-27"],
          [5, 2, 1, "Capacitación Scaling Up Fase 2", "OPE-038 Hoja de datos", "Integral", 1250, 850, 450, 2, 2, 2, "2026-02-03"],
          [5, 2, 2, "Estratos Scaling UP ", "SUP-005 Estratos Scaling UP ", "Integral", 1250, 850, 450, 2, 2, 2, "2026-02-10"],
          [5, 2, 3, "Plan estratégico de una pagina Scaling Up", "SUP-006 y SUP-007", "Integral", 1250, 850, 450, 2, 2, 2, "2026-02-17"],
          [5, 2, 4, "Resumen de Visión Scaling Up", "SUP-008 Resumen de Visión", "Integral", 1250, 850, 450, 2, 2, 2, "2026-02-25"],
          [5, 3, 1, "Detección de necesidades de capacitación", "OPE-037 Detección de necesidades", "Integral", 1250, 850, 450, 1, 1, 1, "2026-03-03"],
          [5, 3, 2, "Cómo hacer la operación más eficiente", "OPE-038 Hoja de datos", "Integral", 1250, 850, 450, 2, 6, 12, "2026-03-10"],
          [5, 3, 3, "Detectar y romper cuellos de botella", "OPE-038 Hoja de datos", "Integral", 1250, 850, 450, 2, 6, 12, "2026-03-17"],
          [5, 4, 1, "Optimización del flujo de trabajo", "OPE-038 Hoja de datos", "Integral", 1250, 850, 450, 2, 6, 12, "2026-04-07"],
          [5, 4, 2, "Estandarizar para crecer", "OPE-038 Hoja de datos", "Integral", 1250, 850, 450, 2, 6, 12, "2026-04-14"],
          [5, 4, 3, "Actualizar validación de modelo de negocio", "OPE-010 Preguntas CANVAS", "Dirección, Procesos, Comercial", 1250, 850, 450, 2, 4, 6, "2026-04-21"],
          [5, 5, 1, "Actualizar Alineación estratégica", "OPE-012 Guía de alineación", "Dirección, Procesos, Comercial", 1250, 850, 450, 2, 4, 6, "2026-05-05"],
          [5, 5, 2, "Actualizar evaluación de dependencia", "OPE-013 Dependencia", "Dirección, Procesos", 1250, 850, 450, 1, 2, 4, "2026-05-12"],
          [5, 5, 3, "Actualizar macroproceso", "OPE-016 Base de datos", "Procesos", 1250, 850, 450, 4, 6, 12, "2026-05-19"],
          [5, 5, 4, "Auditorias y conciliaciones aleatorias", "OPE-020 Conciliación", "Finanzas", 1250, 850, 450, 0.5, 2, 4, "2026-05-26"],
          [5, 6, 1, "Análisis de flujo de efectivo", "OPE-022 Flujo de efectivo", "Finanzas", 1250, 850, 450, 0.5, 2, 4, "2026-06-02"],
          [5, 6, 2, "Análisis de pendientes por cobrar", "OPE-023 Estado de resultados", "Finanzas", 1250, 850, 450, 0.5, 2, 4, "2026-06-09"],
          [5, 6, 3, "Presentar dictamen financiero y acciones", "OPE-024 Dictamen financiero", "Finanzas", 1250, 850, 450, 1, 1, 0, "2026-06-16"],
          [5, 6, 4, "Identificar segmentos y cliente ideal", "OPE-027 Formato Identificación", "Comercial", 1250, 850, 450, 1, 1, 2, "2026-06-23"],
          [5, 7, 1, "Estrategia comercial por segmento (1)", "OPE-028 Formato estrategia", "Comercial", 1250, 850, 450, 2, 4, 12, "2026-07-07"],
          [5, 7, 2, "Estrategia comercial por segmento (2)", "OPE-028 Formato estrategia", "Comercial", 1250, 850, 450, 2, 4, 12, "2026-07-21"],
          [5, 8, 1, "Estrategia comercial por segmento (3)", "OPE-028 Formato estrategia", "Comercial", 1250, 850, 450, 2, 4, 12, "2026-08-04"],
          [5, 8, 2, "Auditoria a proveedores", "OPE-029 Formato alta", "Procesos", 1250, 850, 450, 0, 2, 4, "2026-08-18"],
          [5, 8, 3, "Auditoría a equipo de TI", "OPE-031 Carta responsiva", "Procesos", 1250, 850, 450, 0, 2, 4, "2026-08-25"],
          [5, 9, 1, "Actualizar perfiles de puesto (Área 1 y 2)", "OPE-032 Perfil de puestos", "Dirección, Finanzas", 1250, 850, 450, 2, 4, 8, "2026-09-01"],
          [5, 9, 2, "Actualizar perfiles de puesto (Área 3, 4 y 5)", "OPE-032 Perfil de puestos", "Procesos, Comercial, RH", 1250, 850, 450, 2, 4, 8, "2026-09-08"],
          [5, 9, 3, "Actualizar organigrama", "OPE-033 Organigrama", "RH", 1250, 850, 450, 2, 4, 8, "2026-09-17"],
          [5, 9, 4, "Actualizar matriz RACI", "OPE-034 Matriz RACI", "Dirección, Procesos", 1250, 850, 450, 2, 4, 8, "2026-09-22"],
          [5, 10, 1, "Actualizar y mejorar contrato individual", "OPE-035 Contrato individual", "RH", 1250, 850, 450, 1, 2, 6, "2026-10-06"],
          [5, 10, 2, "Actualizar y mejorar reglamento interno", "OPE-036 Reglamento interno", "RH", 1250, 850, 450, 1, 2, 6, "2026-10-13"],
          [5, 10, 3, "Encuesta de clima organizacional", "OPE-039 Hoja de requisitos web", "Dirección", 1250, 850, 450, 1, 2, 6, "2026-10-20"],
          [5, 11, 1, "Estandarización de procesos", "OPE-018 Documentación procesos", "Procesos", 1250, 850, 450, 2, 4, 8, "2026-11-03"],
          [5, 11, 2, "Estandarización de procesos", "OPE-018 Documentación procesos", "Comercial", 1250, 850, 450, 2, 4, 8, "2026-11-10"],
          [5, 11, 3, "Estandarización de procesos", "OPE-018 Documentación procesos", "RH", 1250, 850, 450, 2, 4, 8, "2026-11-17"],
          [5, 11, 4, "Capacitación en procesos implementados", "OPE-038 Hoja de datos", "Comercial", 1250, 850, 450, 2, 4, 8, "2026-11-24"],
          [5, 12, 1, "Documentación de políticas", "OPE-019 Documentación políticas", "Comercial", 1250, 850, 450, 2, 4, 8, "2026-12-01"],
          [5, 12, 2, "Documentación de políticas", "OPE-019 Documentación políticas", "Comercial", 1250, 850, 450, 2, 4, 8, "2026-12-08"],
          [5, 12, 3, "Capacitación en políticas implementadas", "OPE-038 Hoja de datos", "Dirección", 1250, 850, 450, 2, 4, 8, "2026-12-15"],
          [5, 12, 4, "Elaboración de plan a la medida", "EST-003 Metodología Consilium", "Dirección", 1250, 850, 450, 0.5, 1, 1, "2026-12-22"],
          [5, 12, 4, "Diagnóstico para membresía", "OPE-020 Diagnóstico", "Integral", 1250, 850, 450, 0.5, 1, 1, "2026-12-22"]
        ]

        actividades_creadas = 0

        actividades.each do |row|
          stage_num = row[0]
          mes       = row[1]
          semana    = row[2]
          nombre    = row[3]
          doc_ref   = row[4]
          areas_raw = row[5]
          
          area_principal = areas_raw.split(',').first.to_s.strip
          
          tar_l = row[6].to_f
          tar_s = row[7].to_f
          tar_a = row[8].to_f
          
          hrs_l = row[9].to_f
          hrs_s = row[10].to_f
          hrs_a = row[11].to_f

          fecha_fija = row[12]

          costo_calc = (tar_l * hrs_l) + (tar_s * hrs_s) + (tar_a * hrs_a)
          target_stage = stages_hash[stage_num]

          if target_stage
            target_stage.activities.create!(
              name: nombre,
              month: mes,
              week: semana,
              document_ref: doc_ref,
              area: area_principal,
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
              completed: false,
              created_at: fecha_fija,
              updated_at: fecha_fija
            )
            actividades_creadas += 1
          end
        end

        Rails.logger.info "✅ Template BÁSICA [Y2023] completado: #{actividades_creadas} actividades insertadas (Truncado en Etapa 5)."
      end
    end
  end
end