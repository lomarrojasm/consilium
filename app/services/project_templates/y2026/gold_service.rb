module ProjectTemplates
  module Y2026
    class GoldService
      def self.generate(project, user)
        stages_definitions = [
          "Etapa 1 - Alinear y Diagnosticar",
          "Etapa 2 - Ordenar y Controlar"
        ]

        stages_hash = {}
        stages_definitions.each_with_index do |name, i|
          stages_hash[i + 1] = project.stages.find_or_create_by!(position: i + 1, name: name)
        end

        actividades = [
          # --- ETAPA 1 (24 Tareas) ---
          [1, 1, 1, "Diagnóstico para membresía", "OPE-020 Diagnóstico", "Integral", 1250, 850, 450, 0, 0, 1, "2026-01-05"],
          [1, 1, 1, "Solicitar y revisar expediente", "OPE-001 Check list", "Integral", 1250, 850, 450, 3, 2, 2, "2026-01-05"],
          [1, 1, 1, "Realizar la ficha de datos básicos del cliente", "OPE-002 Ficha", "Integral", 1250, 850, 450, 2, 2, 2, "2026-01-08"],
          [1, 1, 2, "Enviar autodiagnóstico '5 áreas clave'", "OPE-003 Autodiagnóstico", "Integral", 1250, 850, 450, 2, 1, 2, "2026-01-08"],
          [1, 1, 2, "Elaboración de dictamen de hallazgos", "OPE-008 Dictamen", "Integral", 1250, 850, 450, 2, 1, 2, "2026-01-08"],
          [1, 1, 2, "Kick off con dueño y líderes clave", "EST-003 Metodología", "Integral", 1250, 850, 450, 2, 1, 6, "2026-01-12"],
          [1, 1, 2, "Presentación al cliente plan de trabajo etapa 1", "OPE-004 Bitácora", "Integral", 1250, 850, 450, 2, 2, 2, "2026-01-12"],
          [1, 1, 2, "Evaluación de contexto de la empresa", "OPE-006 Preguntas", "Integral", 1250, 850, 450, 1, 1, 1, "2026-01-12"],
          [1, 1, 3, "Presentación de dictamen inicial de hallazgos", "OPE-008 Dictamen", "Integral", 1250, 850, 450, 1, 1, 1, "2026-01-12"],
          [1, 1, 3, "Solicitar documentos clave", "OPE-009 Lista consolidada", "Integral, Procesos", 1250, 850, 450, 2, 1, 3, "2026-01-12"],
          [1, 1, 4, "Sesión de validación de modelo de negocio", "OPE-010 Preguntas CANVAS", "Dirección, Procesos", 1250, 850, 450, 2, 2, 2, "2026-01-19"],
          [1, 1, 4, "Análisis y elaboración de modelo de negocio", "OPE-044 Modelo CANVAS", "Dirección, Procesos", 1250, 850, 450, 1, 4, 4, "2026-01-19"],
          [1, 2, 1, "Presentación de modelo de negocio", "OPE-011 Minuta", "Dirección", 1250, 850, 450, 2, 2, 2, "2026-01-26"],
          [1, 2, 1, "Sesión de solicitud de información Alineación", "OPE-012 Guía", "Dirección", 1250, 850, 450, 2, 2, 2, "2026-02-02"],
          [1, 2, 1, "Análisis y elaboración de modelo de alineación", "OPE-012 Guía", "Dirección", 1250, 850, 450, 2, 4, 4, "2026-02-02"],
          [1, 2, 2, "Presentación de Alineación estratégica", "OPE-011 Minuta", "Dirección", 1250, 850, 450, 2, 2, 2, "2026-02-09"],
          [1, 2, 2, "Sesión de validación de dependencia del dueño", "OPE-014 Dependencia", "Dirección", 1250, 850, 450, 2, 2, 2, "2026-02-16"],
          [1, 2, 2, "Análisis y elaboración de propuestas", "OPE-014 Dependencia", "Dirección", 1250, 850, 450, 4, 4, 4, "2026-02-16"],
          [1, 3, 3, "Presentación de resultados de dependencia", "OPE-011 Minuta", "Procesos", 1250, 850, 450, 2, 2, 0, "2026-02-23"],
          [1, 3, 3, "Sesión de solicitud de información macroproceso", "OPE-016 Base macro proceso", "Procesos", 1250, 850, 450, 4, 4, 4, "2026-03-02"],
          [1, 3, 4, "Análisis y elaboración de macro proceso y KPIs", "OPE-016 Base macro proceso", "Procesos", 1250, 850, 450, 2, 8, 8, "2026-03-02"],
          [1, 3, 4, "Presentación de macroproceso e indicadores", "OPE-011 Minuta", "RH", 1250, 850, 450, 2, 2, 2, "2026-03-09"],
          [1, 3, 4, "Encuesta de clima organizacional", "OPE-043 Encuesta", "Integral", 1250, 850, 450, 2, 2, 2, "2026-03-16"],
          [1, 3, 4, "Elaboración de plan a la medida (etapa 2)", "EST-003 Metodología", "Integral", 1250, 850, 450, 2, 2, 2, "2026-03-23"],

          # --- ETAPA 2 (30 Tareas) ---
          [2, 1, 1, "Presentar plan de actividades etapa 2", "EST-003", "Integral", 1250, 850, 450, 2, 2, 2, "2026-04-07"],
          [2, 1, 1, "Elaborar sistema gestión y seguimiento a KPIs", "OPE-017", "Integral", 1250, 850, 450, 4, 8, 16, "2026-04-14"],
          [2, 1, 2, "Presentar y acordar periodicidad seguimiento KPIs", "OPE-017", "Integral", 1250, 850, 450, 4, 4, 2, "2026-04-21"],
          [2, 1, 3, "Documentar y mapear procesos prioritarios", "OPE-018", "Procesos", 1250, 850, 450, 8, 12, 24, "2026-04-28"],
          [2, 1, 4, "Capacitación en procesos implementados", "OPE-038", "Procesos", 1250, 850, 450, 8, 12, 24, "2026-05-05"],
          [2, 2, 1, "Documentar políticas prioritarias", "OPE-019", "Procesos", 1250, 850, 450, 2, 8, 8, "2026-05-12"],
          [2, 2, 2, "Capacitación en políticas documentadas", "OPE-038", "Procesos", 1250, 850, 450, 2, 8, 8, "2026-05-19"],
          [2, 2, 3, "Matriz de responsabilidades (RACI)", "OPE-034", "RH", 1250, 850, 450, 2, 8, 8, "2026-06-02"],
          [2, 2, 4, "Organigrama", "Organigrama", "RH", 1250, 850, 450, 2, 2, 2, "2026-06-09"],
          [2, 3, 1, "Capacitación comunicación de responsabilidades", "OPE-038", "RH", 1250, 850, 450, 4, 8, 16, "2026-06-16"],
          [2, 3, 2, "Detección de necesidades de capacitación", "OPE-037", "Procesos", 1250, 850, 450, 2, 2, 2, "2026-06-23"],
          [2, 3, 3, "Capacitación Cómo trabajar por procesos", "OPE-038", "Procesos", 1250, 850, 450, 4, 12, 24, "2026-07-07"],
          [2, 4, 4, "Capacitación Mapa general de procesos", "OPE-038", "Procesos", 1250, 850, 450, 4, 12, 24, "2026-07-14"],
          [2, 4, 4, "Capacitación Indicadores clave por proceso", "OPE-038", "Procesos", 1250, 850, 450, 4, 12, 24, "2026-07-21"],
          [2, 5, 1, "Capacitación Juntas de seguimiento efectivas", "OPE-038", "Comercial", 1250, 850, 450, 4, 12, 24, "2026-07-28"],
          [2, 5, 2, "Identificación de segmentos y cliente ideal", "OPE-027", "Comercial", 1250, 850, 450, 4, 8, 16, "2026-08-04"],
          [2, 6, 1, "Estrategia comercial por segmento (1)", "OPE-028", "Comercial", 1250, 850, 450, 4, 12, 24, "2026-08-11"],
          [2, 6, 2, "Estrategia comercial por segmento (2)", "OPE-028", "Comercial", 1250, 850, 450, 4, 12, 24, "2026-08-25"],
          [2, 7, 1, "Estrategia comercial por segmento (3)", "OPE-028", "Procesos", 1250, 850, 450, 4, 12, 24, "2026-09-08"],
          [2, 7, 2, "Alta y evaluación de proveedores", "OPE-029", "Procesos", 1250, 850, 450, 0, 4, 12, "2026-09-22"],
          [2, 8, 1, "Contrato con proveedores", "OPE-030", "Procesos, RH", 1250, 850, 450, 2, 4, 12, "2026-10-06"],
          [2, 8, 2, "Carta responsiva de equipo de TI", "OPE-031", "Dirección", 1250, 850, 450, 1, 2, 12, "2026-10-27"],
          [2, 8, 3, "Perfil de puestos (Área 1)", "OPE-032", "Finanzas", 1250, 850, 450, 1, 2, 8, "2026-11-03"],
          [2, 8, 4, "Perfil de puestos (Área 2)", "OPE-032", "Procesos", 1250, 850, 450, 1, 2, 8, "2026-11-10"],
          [2, 9, 1, "Perfil de puestos (Área 3)", "OPE-032", "Comercial", 1250, 850, 450, 1, 2, 8, "2026-11-17"],
          [2, 9, 2, "Perfil de puestos (Área 4)", "OPE-032", "RH", 1250, 850, 450, 1, 2, 8, "2026-11-24"],
          [2, 9, 3, "Perfil de puestos (Área 5)", "OPE-032", "RH", 1250, 850, 450, 1, 2, 8, "2026-12-01"],
          [2, 9, 4, "Matriz de gestión de empleados", "OPE-041", "Integral", 1250, 850, 450, 1, 2, 2, "2026-12-08"],
          [2, 9, 4, "Diagnóstico para membresía", "OPE-020", "Dirección", 1250, 850, 450, 2, 4, 16, "2026-12-15"],
          [2, 9, 4, "Elaboración de plan a la medida (etapa 3)", "EST-003", "Integral", 1250, 850, 450, 1, 2, 2, "2026-12-15"]
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

        Rails.logger.info "✅ Template GOLD [Y2026] completado: #{actividades_creadas} actividades insertadas (Truncado en Etapa 2)."
      end
    end
  end
end