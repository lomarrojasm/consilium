module ProjectTemplates
  module Y2025
    class GoldService
      def self.generate(project, user)
        stages_definitions = [
          "Etapa 1 - Alinear y Diagnosticar",
          "Etapa 2 - Ordenar y Controlar",
          "Etapa 3 - Estandarizar y Profesionalizar"
        ]

        stages_hash = {}
        stages_definitions.each_with_index do |name, i|
          stages_hash[i + 1] = project.stages.find_or_create_by!(position: i + 1, name: name)
        end

        actividades = [
          # --- ETAPA 1 (24 Tareas) ---
          [1, 1, 1, "Diagnóstico para membresía", "OPE-020 Diagnóstico", "Integral", 1250, 850, 450, 0, 0, 1, "2025-01-07"],
          [1, 1, 1, "Solicitar y revisar expediente", "OPE-001 Check list", "Integral", 1250, 850, 450, 3, 2, 2, "2025-01-07"],
          [1, 1, 1, "Realizar la ficha de datos básicos del cliente", "OPE-002 Ficha", "Integral", 1250, 850, 450, 2, 2, 2, "2025-01-10"],
          [1, 1, 2, "Enviar autodiagnóstico '5 áreas clave'", "OPE-003 Autodiagnóstico", "Integral", 1250, 850, 450, 2, 1, 2, "2025-01-10"],
          [1, 1, 2, "Elaboración de dictamen de hallazgos", "OPE-008 Dictamen", "Integral", 1250, 850, 450, 2, 1, 2, "2025-01-10"],
          [1, 1, 2, "Kick off con dueño y líderes clave", "EST-003 Metodología", "Integral", 1250, 850, 450, 2, 1, 6, "2025-01-14"],
          [1, 1, 2, "Presentación al cliente plan de trabajo etapa 1", "OPE-004 Bitácora", "Integral", 1250, 850, 450, 2, 2, 2, "2025-01-14"],
          [1, 1, 2, "Evaluación de contexto de la empresa", "OPE-006 Preguntas", "Integral", 1250, 850, 450, 1, 1, 1, "2025-01-14"],
          [1, 1, 3, "Presentación de dictamen inicial de hallazgos", "OPE-008 Dictamen", "Integral", 1250, 850, 450, 1, 1, 1, "2025-01-14"],
          [1, 1, 3, "Solicitar documentos clave", "OPE-009 Lista consolidada", "Integral, Procesos", 1250, 850, 450, 2, 1, 3, "2025-01-14"],
          [1, 1, 4, "Sesión de validación de modelo de negocio", "OPE-010 Preguntas CANVAS", "Dirección, Procesos", 1250, 850, 450, 2, 2, 2, "2025-01-21"],
          [1, 1, 4, "Análisis y elaboración de modelo de negocio", "OPE-044 Modelo CANVAS", "Dirección, Procesos", 1250, 850, 450, 1, 4, 4, "2025-01-21"],
          [1, 2, 1, "Presentación de modelo de negocio", "OPE-011 Minuta", "Dirección", 1250, 850, 450, 2, 2, 2, "2025-01-28"],
          [1, 2, 1, "Sesión de solicitud de información Alineación", "OPE-012 Guía", "Dirección", 1250, 850, 450, 2, 2, 2, "2025-02-04"],
          [1, 2, 1, "Análisis y elaboración de modelo de alineación", "OPE-012 Guía", "Dirección", 1250, 850, 450, 2, 4, 4, "2025-02-04"],
          [1, 2, 2, "Presentación de Alineación estratégica", "OPE-011 Minuta", "Dirección", 1250, 850, 450, 2, 2, 2, "2025-02-11"],
          [1, 2, 2, "Sesión de validación de dependencia del dueño", "OPE-014 Dependencia", "Dirección", 1250, 850, 450, 2, 2, 2, "2025-02-18"],
          [1, 2, 2, "Análisis y elaboración de propuestas", "OPE-014 Dependencia", "Dirección", 1250, 850, 450, 4, 4, 4, "2025-02-18"],
          [1, 3, 3, "Presentación de resultados de dependencia", "OPE-011 Minuta", "Procesos", 1250, 850, 450, 2, 2, 0, "2025-02-25"],
          [1, 3, 3, "Sesión de solicitud de información macroproceso", "OPE-016 Base macro proceso", "Procesos", 1250, 850, 450, 4, 4, 4, "2025-03-04"],
          [1, 3, 4, "Análisis y elaboración de macro proceso y KPIs", "OPE-016 Base macro proceso", "Procesos", 1250, 850, 450, 2, 8, 8, "2025-03-04"],
          [1, 3, 4, "Presentación de macroproceso e indicadores", "OPE-011 Minuta", "RH", 1250, 850, 450, 2, 2, 2, "2025-03-11"],
          [1, 3, 4, "Encuesta de clima organizacional", "OPE-043 Encuesta", "Integral", 1250, 850, 450, 2, 2, 2, "2025-03-18"],
          [1, 3, 4, "Elaboración de plan a la medida (etapa 2)", "EST-003 Metodología", "Integral", 1250, 850, 450, 2, 2, 2, "2025-03-25"],

          # --- ETAPA 2 (30 Tareas) ---
          [2, 1, 1, "Presentar plan de actividades etapa 2", "EST-003", "Integral", 1250, 850, 450, 2, 2, 2, "2025-04-01"],
          [2, 1, 1, "Elaborar sistema gestión y seguimiento a KPIs", "OPE-017", "Integral", 1250, 850, 450, 4, 8, 16, "2025-04-08"],
          [2, 1, 2, "Presentar y acordar periodicidad seguimiento KPIs", "OPE-017", "Integral", 1250, 850, 450, 4, 4, 2, "2025-04-15"],
          [2, 1, 3, "Documentar y mapear procesos prioritarios", "OPE-018", "Procesos", 1250, 850, 450, 8, 12, 24, "2025-04-22"],
          [2, 1, 4, "Capacitación en procesos implementados", "OPE-038", "Procesos", 1250, 850, 450, 8, 12, 24, "2025-05-06"],
          [2, 2, 1, "Documentar políticas prioritarias", "OPE-019", "Procesos", 1250, 850, 450, 2, 8, 8, "2025-05-20"],
          [2, 2, 2, "Capacitación en políticas documentadas", "OPE-038", "Procesos", 1250, 850, 450, 2, 8, 8, "2025-05-27"],
          [2, 2, 3, "Matriz de responsabilidades (RACI)", "OPE-034", "RH", 1250, 850, 450, 2, 8, 8, "2025-06-03"],
          [2, 2, 4, "Organigrama", "Organigrama", "RH", 1250, 850, 450, 2, 2, 2, "2025-06-10"],
          [2, 3, 1, "Capacitación comunicación de responsabilidades", "OPE-038", "RH", 1250, 850, 450, 4, 8, 16, "2025-06-17"],
          [2, 3, 2, "Detección de necesidades de capacitación", "OPE-037", "Procesos", 1250, 850, 450, 2, 2, 2, "2025-06-24"],
          [2, 3, 3, "Capacitación Cómo trabajar por procesos", "OPE-038", "Procesos", 1250, 850, 450, 4, 12, 24, "2025-07-01"],
          [2, 4, 4, "Capacitación Mapa general de procesos", "OPE-038", "Procesos", 1250, 850, 450, 4, 12, 24, "2025-07-08"],
          [2, 4, 4, "Capacitación Indicadores clave por proceso", "OPE-038", "Procesos", 1250, 850, 450, 4, 12, 24, "2025-07-15"],
          [2, 5, 1, "Capacitación Juntas de seguimiento efectivas", "OPE-038", "Comercial", 1250, 850, 450, 4, 12, 24, "2025-07-22"],
          [2, 5, 2, "Identificación de segmentos y cliente ideal", "OPE-027", "Comercial", 1250, 850, 450, 4, 8, 16, "2025-08-05"],
          [2, 6, 1, "Estrategia comercial por segmento (1)", "OPE-028", "Comercial", 1250, 850, 450, 4, 12, 24, "2025-08-12"],
          [2, 6, 2, "Estrategia comercial por segmento (2)", "OPE-028", "Comercial", 1250, 850, 450, 4, 12, 24, "2025-09-02"],
          [2, 7, 1, "Estrategia comercial por segmento (3)", "OPE-028", "Procesos", 1250, 850, 450, 4, 12, 24, "2025-09-17"],
          [2, 7, 2, "Alta y evaluación de proveedores", "OPE-029", "Procesos", 1250, 850, 450, 0, 4, 12, "2025-10-01"],
          [2, 8, 1, "Contrato con proveedores", "OPE-030", "Procesos, RH", 1250, 850, 450, 2, 4, 12, "2025-10-14"],
          [2, 8, 2, "Carta responsiva de equipo de TI", "OPE-031", "Dirección", 1250, 850, 450, 1, 2, 12, "2025-11-04"],
          [2, 8, 3, "Perfil de puestos (Área 1)", "OPE-032", "Finanzas", 1250, 850, 450, 1, 2, 8, "2025-11-11"],
          [2, 8, 4, "Perfil de puestos (Área 2)", "OPE-032", "Procesos", 1250, 850, 450, 1, 2, 8, "2025-11-18"],
          [2, 9, 1, "Perfil de puestos (Área 3)", "OPE-032", "Comercial", 1250, 850, 450, 1, 2, 8, "2025-11-25"],
          [2, 9, 2, "Perfil de puestos (Área 4)", "OPE-032", "RH", 1250, 850, 450, 1, 2, 8, "2025-12-02"],
          [2, 9, 3, "Perfil de puestos (Área 5)", "OPE-032", "RH", 1250, 850, 450, 1, 2, 8, "2025-12-09"],
          [2, 9, 4, "Matriz de gestión de empleados", "OPE-041", "Integral", 1250, 850, 450, 1, 2, 2, "2025-12-16"],
          [2, 9, 4, "Diagnóstico para membresía", "OPE-020", "Dirección", 1250, 850, 450, 2, 4, 16, "2025-12-20"],
          [2, 9, 4, "Elaboración de plan a la medida (etapa 3)", "EST-003", "Integral", 1250, 850, 450, 1, 2, 2, "2025-12-20"],

          # --- ETAPA 3 (32 Tareas) ---
          [3, 1, 1, "Presentar plan de actividades etapa 3", "EST-003", "Integral", 1250, 850, 450, 2, 2, 2, "2026-01-07"],
          [3, 1, 2, "Matriz de responsabilidades (RACI)", "OPE-034", "Integral", 1250, 850, 450, 1, 4, 12, "2026-01-13"],
          [3, 1, 3, "Actualizar y mejorar contrato individual", "OPE-035", "RH", 1250, 850, 450, 2, 2, 8, "2026-01-20"],
          [3, 1, 4, "Actualizar y mejorar reglamento interno", "OPE-036", "RH", 1250, 850, 450, 2, 2, 8, "2026-01-27"],
          [3, 2, 1, "Detección de necesidades de capacitación", "OPE-037", "Integral", 1250, 850, 450, 2, 2, 6, "2026-02-03"],
          [3, 2, 2, "Capacitación cómo estandarizar", "OPE-038", "Procesos", 1250, 850, 450, 2, 2, 6, "2026-02-10"],
          [3, 2, 3, "Capacitación procedimientos simples", "OPE-038", "Procesos", 1250, 850, 450, 2, 2, 6, "2026-02-17"],
          [3, 2, 4, "Capacitación usar checklists", "OPE-038", "Procesos", 1250, 850, 450, 2, 2, 6, "2026-02-24"],
          [3, 3, 1, "Capacitación control documentos", "OPE-038", "Procesos", 1250, 850, 450, 2, 2, 6, "2026-03-03"],
          [3, 3, 2, "Capacitación Scaling Up Fase 1", "OPE-038", "Dirección", 1250, 850, 450, 4, 4, 4, "2026-03-10"],
          [3, 3, 3, "Plan Personal de una pagina Scaling Up", "SUP-001", "Dirección", 1250, 850, 450, 4, 4, 4, "2026-03-17"],
          [3, 3, 4, "Tabla responsabilidades por función Scaling Up", "SUP-002", "Dirección", 1250, 850, 450, 4, 4, 4, "2026-03-24"],
          [3, 4, 1, "Tabla responsabilidades por proceso Scaling Up", "SUP-003", "Dirección", 1250, 850, 450, 4, 4, 4, "2026-03-01"],
          [3, 4, 2, "Formulario fortalezas Scaling Up", "SUP-004", "Dirección", 1250, 850, 450, 2, 2, 6, "2026-03-07"],
          [3, 5, 3, "Documentación de políticas", "OPE-019", "Dirección", 1250, 850, 450, 4, 8, 24, "2026-03-14"],
          [3, 5, 3, "Documentación de políticas (cont)", "OPE-019", "Dirección", 1250, 850, 450, 4, 8, 24, "2026-05-05"],
          [3, 5, 4, "Capacitación en políticas", "OPE-038", "Dirección", 1250, 850, 450, 4, 8, 24, "2026-05-19"],
          [3, 6, 1, "Estandarización de procesos", "OPE-018", "Dirección", 1250, 850, 450, 4, 8, 24, "2026-06-02"],
          [3, 6, 2, "Estandarización de procesos (cont)", "OPE-018", "Dirección", 1250, 850, 450, 4, 8, 24, "2026-06-16"],
          [3, 7, 1, "Estandarización de procesos (fin)", "OPE-018", "Dirección", 1250, 850, 450, 2, 4, 12, "2026-07-07"],
          [3, 7, 2, "Capacitación en procesos", "OPE-038", "Dirección", 1250, 850, 450, 2, 12, 48, "2026-07-21"],
          [3, 8, 1, "Capacitación Scaling Up Fase 2", "OPE-038", "Dirección", 1250, 850, 450, 8, 8, 8, "2026-08-04"],
          [3, 8, 2, "Estratos Scaling UP", "SUP-005", "Dirección", 1250, 850, 450, 4, 4, 4, "2026-08-18"],
          [3, 9, 1, "Plan estratégico Scaling Up", "SUP-006", "Dirección", 1250, 850, 450, 4, 4, 4, "2026-09-01"],
          [3, 9, 2, "Resumen de Visión Scaling Up", "SUP-008", "Dirección", 1250, 850, 450, 4, 4, 4, "2026-09-15"],
          [3, 10, 1, "Ejecución Scaling Up", "SUP-009", "Dirección", 1250, 850, 450, 4, 4, 4, "2026-10-06"],
          [3, 10, 2, "Evaluación Hábitos Rockefeller", "SUP-010", "Finanzas", 1250, 850, 450, 4, 4, 4, "2026-10-20"],
          [3, 11, 1, "Estrategias de aceleración", "SUP-011", "Finanzas", 1250, 850, 450, 4, 4, 4, "2026-11-03"],
          [3, 11, 2, "El poder del uno Scaling Up", "SUP-012", "Finanzas", 1250, 850, 450, 4, 4, 4, "2026-11-17"],
          [3, 12, 1, "Retroalimentación Scaling Up", "OPE-041", "Integral", 1250, 850, 450, 4, 12, 48, "2026-12-01"],
          [3, 12, 2, "Elaboración plan a la medida", "EST-003", "Integral", 1250, 850, 450, 1, 2, 2, "2026-12-15"],
          [3, 12, 3, "Diagnóstico para membresía", "OPE-020", "Integral", 1250, 850, 450, 0, 0, 1, "2026-12-15"]
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
              activity_number: row[2],
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

        Rails.logger.info "✅ Template GOLD [Y2025] completado: #{actividades_creadas} actividades insertadas (Truncado en Etapa 3)."
      end
    end
  end
end