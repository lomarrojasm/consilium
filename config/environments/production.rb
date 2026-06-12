require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.hosts.clear # Limpia configuraciones previas

  # === CONFIGURACIÓN DE DOMINIOS ===
  config.hosts << "74.208.227.22" # Mantenemos la IP por si acaso
  config.hosts << "consiliumconsultoria.app"
  config.hosts << "www.consiliumconsultoria.app"
  config.hosts << /.*\.local/     # Permite hosts internos

  # Excluimos el healthcheck de la autorización de host
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present? || true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # === CONFIGURACIÓN SSL (HTTPS) ===
  # Asume que el proxy (Kamal Proxy) se encarga de la terminación SSL
  config.assume_ssl = true

  # Fuerza todo el acceso a la app por SSL (HTTPS), usa Strict-Transport-Security y cookies seguras.
  config.force_ssl = true

  # EVITA QUE EL HEALTHCHECK DE KAMAL FALLE POR REDIRECCIONES HTTPS
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  # Configuración de Logs: Doble salida (Consola + Archivo) con rotación mensual
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    # 1. Asegura que la carpeta log existe para evitar el error "File Not Found"
    log_dir = Rails.root.join("log")
    FileUtils.mkdir_p(log_dir) unless File.directory?(log_dir)

    # 2. Definimos el archivo físico (Guarda 1 respaldo y rota cada mes)
    file_logger = ActiveSupport::Logger.new(log_dir.join("#{Rails.env}.log"), 1, "monthly")
    file_logger.formatter = config.log_formatter

    # 3. Mantenemos la salida a consola para Kamal
    stdout_logger = ActiveSupport::Logger.new(STDOUT)
    stdout_logger.formatter = config.log_formatter

    # 4. Broadcast: Escribe en ambos lugares al mismo tiempo
    config.logger = ActiveSupport::TaggedLogging.new(
      ActiveSupport::BroadcastLogger.new(stdout_logger, file_logger)
    )
  end

  config.log_tags = [ :request_id ]

  # Change to "debug" to log everything (including potentially personally-identifiable information!)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :solid_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  config.active_job.queue_adapter = :solid_queue
  # Configura los correos para que usen deliver_later por defecto
  config.action_mailer.deliver_later_queue_name = "mailers"
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # === CONFIGURACIÓN DE MAILERS (ENLACES DE CORREO) ===
  # Asegura que los links enviados por correo apunten al dominio con https
  config.action_mailer.default_options = { from: ENV["MAILER_SENDER"] }
  config.action_mailer.default_url_options = { host: "consiliumconsultoria.app", protocol: "https" }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Configuración del servidor SMTP
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.smtp_settings = {
    address:              ENV["SMTP_ADDRESS"] || "localhost",
    port:                 (ENV["SMTP_PORT"] || 465).to_i,
    domain:               ENV["SMTP_DOMAIN"] || "localhost",
    user_name:            ENV["SMTP_USERNAME"],
    password:             ENV["SMTP_PASSWORD"],
    authentication:       :plain,
    tls:                  true
  }
end
