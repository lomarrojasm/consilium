require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Hyper
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.to_prepare do
      # 1. Pantallas PÚBLICAS (Login, Olvidé contraseña, etc) -> Usan layout "devise" (Limpio)
      Devise::SessionsController.layout "devise"
      Devise::ConfirmationsController.layout "devise"
      Devise::UnlocksController.layout "devise"
      Devise::PasswordsController.layout "devise"

      # 2. INVITACIONES (Lógica Mixta)
      # - Cuando el usuario hace clic en el correo para aceptar y poner su password ('edit'), usa layout limpio.
      # - Cuando TÚ envías la invitación desde el panel ('new'), usa el layout normal del dashboard.
      Devise::InvitationsController.layout "devise", only: [:edit, :update]

      # 3. REGISTRO / PERFIL
      # IMPORTANTE: No incluimos Devise::RegistrationsController aquí.
      # Razón: Como desactivaste el registro público, la única pantalla que queda es "Editar Perfil".
      # Esa pantalla DEBE tener el sidebar y topbar, así que dejamos que use el layout "application" por defecto.
    end

    # 1. Idioma por defecto
    config.i18n.default_locale = :es

    # 2. Zona Horaria (Para que created_at guarde la hora de México)
    config.time_zone = 'Mexico City'
    
    # Opcional: Permitir traducciones fallidas (útil en desarrollo)
    config.i18n.fallbacks = true


  end
end
