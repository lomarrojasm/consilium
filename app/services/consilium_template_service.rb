class ConsiliumTemplateService
  def self.generate_structure(project, user)
    # Convertimos el valor a string y a minúsculas para que la comparación nunca falle
    membership_type = project.client.membership.to_s.downcase

    # Evaluamos considerando tanto el ID numérico como el nombre del Enum
    if membership_type == '1' || membership_type == 'gold'
      Rails.logger.info "🌟 Enrutando a Membresía GOLD"
      TemplateGoldService.generate(project, user)
      
    elsif membership_type == '2' || membership_type == 'platinum'
      Rails.logger.info "💎 Enrutando a Membresía PLATINUM"
      TemplatePlatinumService.generate(project, user)
      
    else
      Rails.logger.info "🔹 Enrutando a Membresía BÁSICA (Default)"
      TemplateBasicaService.generate(project, user)
    end
  end
end