class ConsiliumTemplateService
  # Agregamos year como tercer parámetro
  def self.generate_structure(project, user, year = nil)
    membership_type = project.client.membership.to_s.downcase

    # Si el usuario seleccionó un año válido (ej. "2022")
    if year.present?
      # Construimos el nombre dinámico del módulo (Ej: ProjectTemplates::Y2022)
      service_namespace = "ProjectTemplates::Y#{year}"
      
      service_name = case membership_type
                     when '1', 'gold' then "GoldService"
                     when '2', 'platinum' then "PlatinumService"
                     else "BasicaService"
                     end

      begin
        # Convierte el string "ProjectTemplates::Y2022::GoldService" en una Clase real
        full_service_class = "#{service_namespace}::#{service_name}".constantize
        
        Rails.logger.info "🌟 Ejecutando Plantilla Histórica: #{full_service_class}"
        full_service_class.generate(project, user)
        
      rescue NameError
        # Si por alguna razón eligieron un año que aún no tiene archivo creado, no rompemos la app
        Rails.logger.error "❌ Faltan archivos para #{year}. Cayendo a plantilla estándar."
        fallback_to_default(project, user, membership_type)
      end

    else
      # Si eligió "Sin año", usamos las plantillas originales (sin fechas hardcodeadas)
      fallback_to_default(project, user, membership_type)
    end
  end

  def self.append_stage_activities(stage, membership_type, user)
    # Selecciona la matriz base dependiendo de la membresía del cliente
    matrix = case membership_type.to_s.downcase
             when '1', 'gold' then TemplateGoldService.activities_matrix
             when '2', 'platinum' then TemplatePlatinumService.activities_matrix
             else TemplateBasicaService.activities_matrix
             end

    # Filtra solo las actividades de la etapa solicitada
    actividades_filtradas = matrix.select { |row| row[0].to_s == stage.template_stage_number.to_s }
    
    actividades_filtradas.each do |row|
      area_principal = row[5].to_s.split(',').first.to_s.strip
      tar_l, tar_s, tar_a = row[6].to_f, row[7].to_f, row[8].to_f
      hrs_l, hrs_s, hrs_a = row[9].to_f, row[10].to_f, row[11].to_f
      costo_calc = (tar_l * hrs_l) + (tar_s * hrs_s) + (tar_a * hrs_a)

      stage.activities.create!(
        activity_number: row[2], # Posición/Semana original
        name: row[3],
        month: row[1],
        week: row[2],
        document_ref: row[4],
        area: area_principal,
        activity_cost: costo_calc,
        leader_rate: tar_l, senior_rate: tar_s, analyst_rate: tar_a,
        leader_hours: hrs_l, senior_hours: hrs_s, analyst_hours: hrs_a,
        user_id: user.id,
        responsible_id: user.id,
        status: 'pending',
        completed: false
      )
    end

    Rails.logger.info "✅ Actividades inyectadas a la etapa manual (Plantilla Etapa #{stage.template_stage_number})"
  end

  private

  # Método auxiliar para cargar las plantillas originales (fechas actuales)
  def self.fallback_to_default(project, user, membership_type)
    if membership_type == '1' || membership_type == 'gold'
      Rails.logger.info "🌟 Enrutando a Membresía GOLD (Estándar de Hoy)"
      TemplateGoldService.generate(project, user)
      
    elsif membership_type == '2' || membership_type == 'platinum'
      Rails.logger.info "💎 Enrutando a Membresía PLATINUM (Estándar de Hoy)"
      TemplatePlatinumService.generate(project, user)
      
    else
      Rails.logger.info "🔹 Enrutando a Membresía BÁSICA (Estándar de Hoy)"
      TemplateBasicaService.generate(project, user)
    end
  end
end