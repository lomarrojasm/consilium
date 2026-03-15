class TemplatePlatinumService
  def self.activities_matrix
    [
      # --- ETAPA 1 (24 Tareas) ---
      [1, 1, 1, "Diagnóstico para membresía", "OPE-020 Diagnóstico", "Integral", 1250, 850, 450, 0, 0, 1],
      [1, 1, 1, "Solicitar y revisar expediente", "OPE-001 Check list", "Integral", 1250, 850, 450, 6, 4, 4],
      [1, 1, 1, "Realizar ficha de datos básicos", "OPE-002 Ficha", "Integral", 1250, 850, 450, 4, 4, 4],
      [1, 1, 2, "Enviar autodiagnóstico", "OPE-003 Autodiagnóstico", "Integral", 1250, 850, 450, 4, 2, 4],
      [1, 1, 2, "Elaboración de dictamen de hallazgos", "OPE-008 Dictamen", "Integral", 1250, 850, 450, 4, 2, 4],
      [1, 1, 2, "Kick off con dueño y líderes", "EST-003 Metodología", "Integral", 1250, 850, 450, 4, 2, 12],
      [1, 1, 2, "Presentación plan de trabajo", "OPE-004 Bitácora", "Integral", 1250, 850, 450, 4, 4, 4],
      [1, 1, 2, "Evaluación de contexto", "OPE-006 Preguntas", "Integral", 1250, 850, 450, 2, 2, 2],
      [1, 1, 3, "Presentación dictamen inicial", "OPE-008 Dictamen", "Integral", 1250, 850, 450, 2, 2, 2],
      [1, 1, 3, "Solicitar documentos clave", "OPE-009 Lista", "Dirección", 1250, 850, 450, 4, 2, 6],
      [1, 1, 4, "Sesión validación modelo", "OPE-010 Preguntas CANVAS", "Dirección", 1250, 850, 450, 4, 4, 4],
      [1, 1, 4, "Análisis y elaboración modelo negocio", "OPE-044 Modelo CANVAS", "Dirección", 1250, 850, 450, 2, 8, 8],
      [1, 2, 1, "Presentación modelo de negocio", "OPE-011 Minuta", "Dirección", 1250, 850, 450, 4, 4, 4],
      [1, 2, 1, "Sesión de solicitud de información Alineación", "OPE-012 Guía", "Dirección", 1250, 850, 450, 4, 4, 4],
      [1, 2, 1, "Análisis y elaboración modelo alineación", "OPE-012 Guía", "Dirección", 1250, 850, 450, 4, 8, 8],
      [1, 2, 2, "Presentación Alineación estratégica", "OPE-011 Minuta", "Dirección", 1250, 850, 450, 4, 4, 4],
      [1, 2, 2, "Sesión validación dependencia dueño", "OPE-014 Dependencia", "Dirección", 1250, 850, 450, 4, 4, 4],
      [1, 2, 2, "Análisis propuestas acciones correctivas", "OPE-014 Dependencia", "Dirección", 1250, 850, 450, 8, 8, 8],
      [1, 3, 3, "Presentación resultados dependencia", "OPE-011 Minuta", "Procesos", 1250, 850, 450, 4, 4, 4],
      [1, 3, 3, "Sesión solicitud macroproceso", "OPE-016 Base macro proceso", "Procesos", 1250, 850, 450, 8, 8, 8],
      [1, 3, 4, "Análisis y elaboración macro proceso", "OPE-016 Base macro proceso", "Procesos", 1250, 850, 450, 4, 16, 16],
      [1, 3, 4, "Presentación macroproceso", "OPE-011 Minuta", "RH", 1250, 850, 450, 4, 4, 4],
      [1, 3, 4, "Encuesta clima organizacional", "OPE-043 Encuesta", "Integral", 1250, 850, 450, 4, 4, 4],
      [1, 3, 4, "Elaboración plan a la medida", "EST-003 Metodología", "Integral", 1250, 850, 450, 4, 4, 4],

      # --- ETAPA 2 (30 Tareas) ---
      [2, 1, 1, "Presentar plan etapa 2", "EST-003", "Integral", 1250, 850, 450, 4, 4, 4],
      [2, 1, 1, "Elaborar sistema seguimiento KPIs", "OPE-017", "Integral", 1250, 850, 450, 8, 16, 32],
      [2, 1, 2, "Presentar periodicidad KPIs", "OPE-017", "Integral", 1250, 850, 450, 8, 8, 4],
      [2, 1, 3, "Documentar procesos prioritarios", "OPE-018", "Procesos", 1250, 850, 450, 16, 24, 24],
      [2, 1, 4, "Capacitación en procesos", "OPE-038", "Procesos", 1250, 850, 450, 16, 24, 24],
      [2, 2, 1, "Documentar políticas", "OPE-019", "Procesos", 1250, 850, 450, 4, 16, 16],
      [2, 2, 2, "Capacitación en políticas", "OPE-038", "Procesos", 1250, 850, 450, 4, 16, 16],
      [2, 2, 3, "Matriz de responsabilidades", "OPE-034", "RH", 1250, 850, 450, 4, 16, 16],
      [2, 2, 4, "Organigrama", "Organigrama", "RH", 1250, 850, 450, 4, 4, 4],
      [2, 3, 1, "Capacitación comunicación responsabilidades", "OPE-038", "RH", 1250, 850, 450, 8, 16, 32],
      [2, 3, 2, "Detección necesidades capacitación", "OPE-037", "Procesos", 1250, 850, 450, 8, 16, 32],
      [2, 3, 3, "Capacitación Cómo trabajar por procesos", "OPE-038", "Procesos", 1250, 850, 450, 4, 4, 4],
      [2, 4, 4, "Capacitación Mapa general procesos", "OPE-038", "Procesos", 1250, 850, 450, 8, 24, 24],
      [2, 4, 4, "Capacitación Indicadores clave", "OPE-038", "Procesos", 1250, 850, 450, 8, 24, 24],
      [2, 5, 1, "Capacitación Juntas efectivas", "OPE-038", "Comercial", 1250, 850, 450, 8, 24, 24],
      [2, 5, 2, "Identificación segmentos cliente ideal", "OPE-027", "Comercial", 1250, 850, 450, 8, 24, 24],
      [2, 6, 1, "Estrategia comercial (1)", "OPE-028", "Comercial", 1250, 850, 450, 8, 24, 24],
      [2, 6, 2, "Estrategia comercial (2)", "OPE-028", "Comercial", 1250, 850, 450, 8, 24, 24],
      [2, 7, 1, "Estrategia comercial (3)", "OPE-028", "Procesos", 1250, 850, 450, 8, 24, 24],
      [2, 7, 2, "Alta proveedores", "OPE-029", "Procesos", 1250, 850, 450, 0, 8, 24],
      [2, 8, 1, "Contrato con proveedores", "OPE-030", "Procesos", 1250, 850, 450, 4, 8, 24],
      [2, 8, 2, "Carta responsiva TI", "OPE-031", "Dirección", 1250, 850, 450, 2, 4, 24],
      [2, 8, 3, "Perfil de puestos (1)", "OPE-032", "Finanzas", 1250, 850, 450, 2, 4, 16],
      [2, 8, 4, "Perfil de puestos (2)", "OPE-032", "Procesos", 1250, 850, 450, 2, 4, 16],
      [2, 9, 1, "Perfil de puestos (3)", "OPE-032", "Comercial", 1250, 850, 450, 2, 4, 16],
      [2, 9, 2, "Perfil de puestos (4)", "OPE-032", "RH", 1250, 850, 450, 2, 4, 16],
      [2, 9, 3, "Perfil de puestos (5)", "OPE-032", "RH", 1250, 850, 450, 2, 4, 16],
      [2, 9, 4, "Matriz gestión empleados", "OPE-041", "Integral", 1250, 850, 450, 4, 8, 24],
      [2, 9, 4, "Diagnóstico para membresía", "OPE-020", "Dirección", 1250, 850, 450, 0, 0, 1],
      [2, 9, 4, "Elaboración plan etapa 3", "EST-003", "Integral", 1250, 850, 450, 2, 4, 4],

      # --- ETAPA 3 (32 Tareas) ---
      [3, 1, 1, "Presentar plan etapa 3", "EST-003", "Integral", 1250, 850, 450, 4, 4, 4],
      [3, 1, 2, "Matriz RACI", "OPE-034", "Integral", 1250, 850, 450, 4, 8, 24],
      [3, 1, 3, "Actualizar contrato individual", "OPE-035", "RH", 1250, 850, 450, 4, 4, 16],
      [3, 1, 4, "Actualizar reglamento interno", "OPE-036", "RH", 1250, 850, 450, 4, 4, 16],
      [3, 2, 1, "Detección necesidades capacitación", "OPE-037", "Integral", 1250, 850, 450, 4, 4, 12],
      [3, 2, 2, "Capacitación estandarizar", "OPE-038", "Procesos", 1250, 850, 450, 4, 4, 12],
      [3, 2, 3, "Capacitación procedimientos simples", "OPE-038", "Procesos", 1250, 850, 450, 4, 4, 12],
      [3, 2, 4, "Capacitación checklists", "OPE-038", "Procesos", 1250, 850, 450, 4, 4, 12],
      [3, 3, 1, "Capacitación control documentos", "OPE-038", "Procesos", 1250, 850, 450, 4, 4, 12],
      [3, 3, 2, "Capacitación Scaling Up Fase 1", "OPE-038", "Dirección", 1250, 850, 450, 10, 10, 10],
      [3, 3, 3, "Plan Personal Scaling Up", "SUP-001", "Dirección", 1250, 850, 450, 10, 10, 10],
      [3, 3, 4, "Tabla responsabilidades función", "SUP-002", "Dirección", 1250, 850, 450, 10, 10, 10],
      [3, 4, 1, "Tabla responsabilidades proceso", "SUP-003", "Dirección", 1250, 850, 450, 10, 10, 10],
      [3, 4, 2, "Formulario fortalezas Scaling Up", "SUP-004", "Dirección", 1250, 850, 450, 4, 4, 12],
      [3, 5, 3, "Documentación políticas", "OPE-019", "Dirección", 1250, 850, 450, 8, 24, 24],
      [3, 5, 3, "Documentación políticas (cont)", "OPE-019", "Dirección", 1250, 850, 450, 8, 24, 24],
      [3, 5, 4, "Capacitación políticas", "OPE-038", "Dirección", 1250, 850, 450, 8, 24, 24],
      [3, 6, 1, "Estandarización procesos", "OPE-018", "Dirección", 1250, 850, 450, 8, 24, 24],
      [3, 6, 2, "Estandarización procesos (cont)", "OPE-018", "Dirección", 1250, 850, 450, 8, 24, 24],
      [3, 7, 1, "Estandarización procesos (fin)", "OPE-018", "Dirección", 1250, 850, 450, 8, 24, 24],
      [3, 7, 2, "Capacitación procesos implementados", "OPE-038", "Dirección", 1250, 850, 450, 6, 24, 24],
      [3, 8, 1, "Capacitación Scaling Up Fase 2", "OPE-038", "Dirección", 1250, 850, 450, 16, 16, 16],
      [3, 8, 2, "Estratos Scaling UP", "SUP-005", "Dirección", 1250, 850, 450, 12, 12, 12],
      [3, 9, 1, "Plan estratégico Scaling Up", "SUP-006", "Dirección", 1250, 850, 450, 12, 12, 12],
      [3, 9, 2, "Resumen Visión Scaling Up", "SUP-008", "Dirección", 1250, 850, 450, 12, 12, 12],
      [3, 10, 1, "Ejecución Scaling Up", "SUP-009", "Dirección", 1250, 850, 450, 12, 12, 12],
      [3, 10, 2, "Evaluación Hábitos Rockefeller", "SUP-010", "Finanzas", 1250, 850, 450, 12, 12, 12],
      [3, 11, 1, "Estrategias aceleración efectivo", "SUP-011", "Finanzas", 1250, 850, 450, 12, 12, 12],
      [3, 11, 2, "El poder del uno", "SUP-012", "Finanzas", 1250, 850, 450, 12, 12, 12],
      [3, 12, 1, "Retroalimentación Scaling Up", "OPE-041", "Integral", 1250, 850, 450, 8, 24, 24],
      [3, 12, 2, "Elaboración plan a la medida", "EST-003", "Integral", 1250, 850, 450, 2, 4, 4],
      [3, 12, 3, "Diagnóstico para membresía", "OPE-020", "Integral", 1250, 850, 450, 0, 0, 1],

      # --- ETAPA 4 (43 Tareas) ---
      [4, 1, 1, "Presentar plan etapa 4", "EST-003", "Integral", 1250, 850, 450, 4, 4, 4],
      [4, 1, 2, "Enviar autodiagnóstico", "OPE-003", "Integral", 1250, 850, 450, 2, 2, 2],
      [4, 1, 3, "Analizar resultado dictamen", "OPE-008", "Integral", 1250, 850, 450, 4, 4, 16],
      [4, 1, 4, "Presentar Dictamen", "OPE-008", "Integral", 1250, 850, 450, 4, 4, 4],
      [4, 2, 1, "Plan Personal", "SUP-001", "Dirección", 1250, 850, 450, 8, 8, 8],
      [4, 2, 2, "Tabla responsabilidades función", "SUP-002", "Dirección", 1250, 850, 450, 8, 8, 8],
      [4, 2, 3, "Tabla responsabilidades proceso", "SUP-003", "Dirección", 1250, 850, 450, 8, 8, 8],
      [4, 2, 4, "Formulario fortalezas", "SUP-004", "Dirección", 1250, 850, 450, 8, 8, 8],
      [4, 3, 1, "Detección necesidades", "OPE-037", "Integral", 1250, 850, 450, 4, 4, 4],
      [4, 3, 2, "Capacitación Mejora continua", "OPE-038", "Procesos", 1250, 850, 450, 8, 24, 24],
      [4, 3, 3, "Capacitación Encontrar causa real", "OPE-038", "Procesos", 1250, 850, 450, 8, 24, 24],
      [4, 4, 1, "Capacitación Resolver problemas", "OPE-038", "Procesos", 1250, 850, 450, 8, 24, 24],
      [4, 4, 2, "Capacitación Seguimiento acciones", "OPE-038", "Procesos", 1250, 850, 450, 8, 24, 24],
      [4, 4, 3, "Actualizar CANVAS", "OPE-010", "Dirección", 1250, 850, 450, 8, 16, 24],
      [4, 5, 1, "Actualizar Alineación", "OPE-012", "Dirección", 1250, 850, 450, 8, 16, 24],
      [4, 5, 2, "Actualizar dependencia dueño", "OPE-013", "Dirección", 1250, 850, 450, 4, 8, 16],
      [4, 5, 3, "Actualizar macroproceso", "OPE-016", "Procesos", 1250, 850, 450, 16, 24, 24],
      [4, 5, 4, "Auditorias aleatorias", "OPE-020", "Finanzas", 1250, 850, 450, 2, 8, 16],
      [4, 6, 1, "Análisis flujo efectivo", "OPE-022", "Finanzas", 1250, 850, 450, 2, 8, 16],
      [4, 6, 2, "Análisis pendientes cobrar", "OPE-023", "Finanzas", 1250, 850, 450, 2, 8, 16],
      [4, 6, 3, "Presentar dictamen financiero", "OPE-024", "Finanzas", 1250, 850, 450, 4, 4, 4],
      [4, 6, 4, "Identificar segmentos", "OPE-027", "Comercial", 1250, 850, 450, 4, 4, 8],
      [4, 7, 1, "Estrategia comercial (1)", "OPE-028", "Comercial", 1250, 850, 450, 8, 24, 24],
      [4, 7, 2, "Estrategia comercial (2)", "OPE-028", "Comercial", 1250, 850, 450, 8, 24, 24],
      [4, 8, 1, "Estrategia comercial (3)", "OPE-028", "Comercial", 1250, 850, 450, 8, 24, 24],
      [4, 8, 2, "Auditoria proveedores", "OPE-029", "Procesos", 1250, 850, 450, 4, 8, 16],
      [4, 8, 3, "Auditoría equipo TI", "OPE-031", "Procesos", 1250, 850, 450, 4, 8, 16],
      [4, 9, 1, "Actualizar perfiles (1 y 2)", "OPE-032", "Procesos", 1250, 850, 450, 8, 16, 24],
      [4, 9, 2, "Actualizar perfiles (3, 4 y 5)", "OPE-032", "Procesos", 1250, 850, 450, 8, 16, 24],
      [4, 9, 3, "Actualizar organigrama", "OPE-033", "RH", 1250, 850, 450, 8, 16, 24],
      [4, 9, 4, "Actualizar matriz RACI", "OPE-034", "Dirección", 1250, 850, 450, 8, 16, 24],
      [4, 10, 1, "Actualizar contrato individual", "OPE-035", "RH", 1250, 850, 450, 4, 8, 24],
      [4, 10, 2, "Actualizar reglamento interno", "OPE-036", "RH", 1250, 850, 450, 4, 8, 24],
      [4, 10, 3, "Encuesta clima organizacional", "OPE-043", "RH", 1250, 850, 450, 4, 8, 24],
      [4, 11, 1, "Estandarización procesos", "OPE-018", "Dirección", 1250, 850, 450, 8, 16, 24],
      [4, 11, 2, "Estandarización procesos", "OPE-018", "Dirección", 1250, 850, 450, 8, 16, 24],
      [4, 11, 3, "Estandarización procesos", "OPE-018", "Dirección", 1250, 850, 450, 8, 16, 24],
      [4, 11, 4, "Capacitación procesos", "OPE-038", "Dirección", 1250, 850, 450, 8, 16, 24],
      [4, 12, 1, "Documentación políticas", "OPE-019", "Dirección", 1250, 850, 450, 8, 16, 24],
      [4, 12, 2, "Documentación políticas", "OPE-019", "Dirección", 1250, 850, 450, 8, 16, 24],
      [4, 12, 3, "Capacitación políticas", "OPE-038", "Dirección", 1250, 850, 450, 8, 16, 24],
      [4, 12, 4, "Elaboración plan a la medida", "EST-003", "Dirección", 1250, 850, 450, 2, 4, 4],
      [4, 12, 4, "Diagnóstico para membresía", "OPE-020", "Integral", 1250, 850, 450, 0, 0, 1],

      # --- ETAPA 5 (43 Tareas) ---
      [5, 1, 1, "Presentar plan actividades", "EST-003", "Integral", 1250, 850, 450, 4, 4, 4],
      [5, 1, 2, "Enviar autodiagnóstico", "OPE-003", "Integral", 1250, 850, 450, 2, 2, 2],
      [5, 1, 3, "Analizar resultado dictamen", "OPE-008", "Integral", 1250, 850, 450, 4, 4, 16],
      [5, 1, 4, "Presentar Dictamen", "OPE-008", "Integral", 1250, 850, 450, 4, 4, 4],
      [5, 2, 1, "Capacitación Scaling Up Fase 2", "OPE-038", "Integral", 1250, 850, 450, 8, 8, 8],
      [5, 2, 2, "Estratos Scaling UP", "SUP-005", "Integral", 1250, 850, 450, 8, 8, 8],
      [5, 2, 3, "Plan estratégico de una pagina", "SUP-006", "Integral", 1250, 850, 450, 8, 8, 8],
      [5, 2, 4, "Resumen de Visión", "SUP-008", "Integral", 1250, 850, 450, 8, 8, 8],
      [5, 3, 1, "Detección necesidades", "OPE-037", "Integral", 1250, 850, 450, 4, 4, 4],
      [5, 3, 2, "Hacer operación eficiente", "OPE-038", "Integral", 1250, 850, 450, 8, 24, 24],
      [5, 3, 3, "Detectar cuellos botella", "OPE-038", "Integral", 1250, 850, 450, 8, 24, 24],
      [5, 4, 1, "Optimización flujo trabajo", "OPE-038", "Integral", 1250, 850, 450, 8, 24, 24],
      [5, 4, 2, "Estandarizar para crecer", "OPE-038", "Integral", 1250, 850, 450, 8, 24, 24],
      [5, 4, 3, "Actualizar validación CANVAS", "OPE-010", "Dirección", 1250, 850, 450, 8, 16, 24],
      [5, 5, 1, "Actualizar Alineación", "OPE-012", "Dirección", 1250, 850, 450, 8, 16, 24],
      [5, 5, 2, "Actualizar dependencia dueño", "OPE-013", "Dirección", 1250, 850, 450, 4, 8, 16],
      [5, 5, 3, "Actualizar macroproceso", "OPE-016", "Procesos", 1250, 850, 450, 16, 24, 24],
      [5, 5, 4, "Auditorias aleatorias", "OPE-020", "Finanzas", 1250, 850, 450, 2, 8, 16],
      [5, 6, 1, "Análisis flujo efectivo", "OPE-022", "Finanzas", 1250, 850, 450, 2, 8, 16],
      [5, 6, 2, "Análisis pendientes cobrar", "OPE-023", "Finanzas", 1250, 850, 450, 2, 8, 16],
      [5, 6, 3, "Presentar dictamen financiero", "OPE-024", "Finanzas", 1250, 850, 450, 4, 4, 4],
      [5, 6, 4, "Identificar segmentos", "OPE-027", "Comercial", 1250, 850, 450, 4, 4, 8],
      [5, 7, 1, "Estrategia comercial (1)", "OPE-028", "Comercial", 1250, 850, 450, 8, 24, 24],
      [5, 7, 2, "Estrategia comercial (2)", "OPE-028", "Comercial", 1250, 850, 450, 8, 24, 24],
      [5, 8, 1, "Estrategia comercial (3)", "OPE-028", "Comercial", 1250, 850, 450, 8, 24, 24],
      [5, 8, 2, "Auditoria proveedores", "OPE-029", "Procesos", 1250, 850, 450, 4, 8, 16],
      [5, 8, 3, "Auditoría equipo TI", "OPE-031", "Procesos", 1250, 850, 450, 4, 8, 16],
      [5, 9, 1, "Actualizar perfiles Área 1,2", "OPE-032", "Dirección", 1250, 850, 450, 8, 16, 24],
      [5, 9, 2, "Actualizar perfiles Área 3,4,5", "OPE-032", "Procesos", 1250, 850, 450, 8, 16, 24],
      [5, 9, 3, "Actualizar organigrama", "OPE-033", "RH", 1250, 850, 450, 8, 16, 24],
      [5, 9, 4, "Actualizar matriz RACI", "OPE-034", "Dirección", 1250, 850, 450, 8, 16, 24],
      [5, 10, 1, "Actualizar contrato", "OPE-035", "RH", 1250, 850, 450, 4, 8, 24],
      [5, 10, 2, "Actualizar reglamento", "OPE-036", "RH", 1250, 850, 450, 4, 8, 24],
      [5, 10, 3, "Encuesta clima organizacional", "OPE-039", "Dirección", 1250, 850, 450, 4, 8, 24],
      [5, 11, 1, "Estandarización procesos", "OPE-018", "Procesos", 1250, 850, 450, 8, 16, 24],
      [5, 11, 2, "Estandarización procesos", "OPE-018", "Comercial", 1250, 850, 450, 8, 16, 24],
      [5, 11, 3, "Estandarización procesos", "OPE-018", "RH", 1250, 850, 450, 8, 16, 24],
      [5, 11, 4, "Capacitación procesos", "OPE-038", "Comercial", 1250, 850, 450, 8, 16, 24],
      [5, 12, 1, "Documentación políticas", "OPE-019", "Comercial", 1250, 850, 450, 8, 16, 24],
      [5, 12, 2, "Documentación políticas", "OPE-019", "Comercial", 1250, 850, 450, 8, 16, 24],
      [5, 12, 3, "Capacitación políticas", "OPE-038", "Dirección", 1250, 850, 450, 8, 16, 24],
      [5, 12, 4, "Elaboración plan a la medida", "EST-003", "Dirección", 1250, 850, 450, 2, 4, 4],
      [5, 12, 4, "Diagnóstico membresía", "OPE-020", "Integral", 1250, 850, 450, 0, 0, 1],

      # --- ETAPA 6 (43 Tareas) ---
      [6, 1, 1, "Presentar plan actividades", "EST-003", "Integral", 1250, 850, 450, 4, 4, 4],
      [6, 1, 2, "Enviar autodiagnóstico", "OPE-003", "Integral", 1250, 850, 450, 2, 2, 2],
      [6, 1, 3, "Analizar resultado dictamen", "OPE-008", "Integral", 1250, 850, 450, 4, 4, 16],
      [6, 1, 4, "Presentar Dictamen", "OPE-008", "Integral", 1250, 850, 450, 4, 4, 4],
      [6, 2, 1, "Capacitación Scaling Up Fase 2", "OPE-038", "Integral", 1250, 850, 450, 8, 8, 8],
      [6, 2, 2, "Estratos Scaling UP", "SUP-005", "Integral", 1250, 850, 450, 8, 8, 8],
      [6, 2, 3, "Plan estratégico de una pagina", "SUP-006", "Integral", 1250, 850, 450, 8, 8, 8],
      [6, 2, 4, "Resumen de Visión", "SUP-008", "Integral", 1250, 850, 450, 8, 8, 8],
      [6, 3, 1, "Detección necesidades", "OPE-037", "Integral", 1250, 850, 450, 4, 4, 4],
      [6, 3, 2, "Hacer operación eficiente", "OPE-038", "Integral", 1250, 850, 450, 8, 24, 24],
      [6, 3, 3, "Detectar cuellos botella", "OPE-038", "Integral", 1250, 850, 450, 8, 24, 24],
      [6, 4, 1, "Optimización flujo trabajo", "OPE-038", "Integral", 1250, 850, 450, 8, 24, 24],
      [6, 4, 2, "Estandarizar para crecer", "OPE-038", "Integral", 1250, 850, 450, 8, 24, 24],
      [6, 4, 3, "Actualizar validación CANVAS", "OPE-010", "Dirección", 1250, 850, 450, 8, 16, 24],
      [6, 5, 1, "Actualizar Alineación", "OPE-012", "Dirección", 1250, 850, 450, 8, 16, 24],
      [6, 5, 2, "Actualizar dependencia dueño", "OPE-013", "Dirección", 1250, 850, 450, 4, 8, 16],
      [6, 5, 3, "Actualizar macroproceso", "OPE-016", "Procesos", 1250, 850, 450, 16, 24, 24],
      [6, 5, 4, "Auditorias aleatorias", "OPE-020", "Finanzas", 1250, 850, 450, 2, 8, 16],
      [6, 6, 1, "Análisis flujo efectivo", "OPE-022", "Finanzas", 1250, 850, 450, 2, 8, 16],
      [6, 6, 2, "Análisis pendientes cobrar", "OPE-023", "Finanzas", 1250, 850, 450, 2, 8, 16],
      [6, 6, 3, "Presentar dictamen financiero", "OPE-024", "Finanzas", 1250, 850, 450, 4, 4, 4],
      [6, 6, 4, "Identificar segmentos", "OPE-027", "Comercial", 1250, 850, 450, 4, 4, 8],
      [6, 7, 1, "Estrategia comercial (1)", "OPE-028", "Comercial", 1250, 850, 450, 8, 24, 24],
      [6, 7, 2, "Estrategia comercial (2)", "OPE-028", "Comercial", 1250, 850, 450, 8, 24, 24],
      [6, 8, 1, "Estrategia comercial (3)", "OPE-028", "Comercial", 1250, 850, 450, 8, 24, 24],
      [6, 8, 2, "Auditoria proveedores", "OPE-029", "Procesos", 1250, 850, 450, 4, 8, 16],
      [6, 8, 3, "Auditoría equipo TI", "OPE-031", "Procesos", 1250, 850, 450, 4, 8, 16],
      [6, 9, 1, "Actualizar perfiles (1 y 2)", "OPE-032", "Dirección", 1250, 850, 450, 8, 16, 24],
      [6, 9, 2, "Actualizar perfiles (3, 4 y 5)", "OPE-032", "Procesos", 1250, 850, 450, 8, 16, 24],
      [6, 9, 3, "Actualizar organigrama", "OPE-033", "RH", 1250, 850, 450, 8, 16, 24],
      [6, 9, 4, "Actualizar matriz RACI", "OPE-034", "Dirección", 1250, 850, 450, 8, 16, 24],
      [6, 10, 1, "Actualizar contrato", "OPE-035", "RH", 1250, 850, 450, 4, 8, 24],
      [6, 10, 2, "Actualizar reglamento", "OPE-036", "RH", 1250, 850, 450, 4, 8, 24],
      [6, 10, 3, "Encuesta clima organizacional", "OPE-039", "Dirección", 1250, 850, 450, 4, 8, 24],
      [6, 11, 1, "Estandarización procesos", "OPE-018", "Procesos", 1250, 850, 450, 8, 16, 24],
      [6, 11, 2, "Estandarización procesos", "OPE-018", "Comercial", 1250, 850, 450, 8, 16, 24],
      [6, 11, 3, "Estandarización procesos", "OPE-018", "RH", 1250, 850, 450, 8, 16, 24],
      [6, 11, 4, "Capacitación procesos", "OPE-038", "Comercial", 1250, 850, 450, 8, 16, 24],
      [6, 12, 1, "Documentación políticas", "OPE-019", "Comercial", 1250, 850, 450, 8, 16, 24],
      [6, 12, 2, "Documentación políticas", "OPE-019", "Comercial", 1250, 850, 450, 8, 16, 24],
      [6, 12, 3, "Capacitación políticas", "OPE-038", "Dirección", 1250, 850, 450, 8, 16, 24],
      [6, 12, 4, "Elaboración plan a la medida", "EST-003", "Dirección", 1250, 850, 450, 2, 4, 4],
      [6, 12, 4, "Diagnóstico membresía", "OPE-020", "Integral", 1250, 850, 450, 0, 0, 1]
    ]
  end

  def self.generate(project, user)
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

    actividades_creadas = 0

    self.activities_matrix.each do |row|
      stage_num = row[0]
      mes       = row[1]
      semana    = row[2]
      nombre    = row[3]
      doc_ref   = row[4]
      areas_raw = row[5]
      
      area_principal = areas_raw.split(',').first.to_s.strip
      
      tar_l = row[6].to_f; tar_s = row[7].to_f; tar_a = row[8].to_f
      hrs_l = row[9].to_f; hrs_s = row[10].to_f; hrs_a = row[11].to_f

      costo_calc = (tar_l * hrs_l) + (tar_s * hrs_s) + (tar_a * hrs_a)
      target_stage = stages_hash[stage_num]

      if target_stage
        target_stage.activities.create!(
          activity_number: row[2],
          name: nombre,
          month: mes,
          week: semana,
          document_ref: doc_ref,
          area: area_principal,
          activity_cost: costo_calc,
          leader_rate: tar_l, senior_rate: tar_s, analyst_rate: tar_a,
          leader_hours: hrs_l, senior_hours: hrs_s, analyst_hours: hrs_a,
          user_id: user.id,
          responsible_id: user.id,
          status: 'pending',
          completed: false
        )
        actividades_creadas += 1
      end
    end

    Rails.logger.info "✅ Template PLATINUM (Sin Año) completado exitosamente."
  end
end