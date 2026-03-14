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