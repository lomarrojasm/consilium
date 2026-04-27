# config/initializers/openai.rb
OpenAI.configure do |config|
  # Usamos fetch para que Rails lance un error claro si la variable no existe,
  # en lugar de fallar silenciosamente en producción.
  config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")

  # Opcional: Útil para ver en la terminal de VS Code si hay errores con la API
  config.log_errors = true
end
