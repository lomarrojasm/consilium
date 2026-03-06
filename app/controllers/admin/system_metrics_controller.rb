# app/controllers/admin/system_metrics_controller.rb
require 'net/http'

module Admin
  class SystemMetricsController < ApplicationController
    # Usamos tu método existente en ApplicationController
    before_action :authorize_admin!
    
    # Si tienes un layout específico para admin, cámbialo aquí. 
    # Si no, "application" funcionará con tu barra lateral.
    layout "application"

    def index
      # Carga la vista principal de monitoreo
    end

    def chart_data
      # El "Túnel" hacia Netdata
      chart = params[:chart]
      host = "74.208.227.22"
      
      # Codificación segura del nombre del gráfico (ej: disk_space./ -> disk_space.%2F)
      encoded_chart = ERB::Util.url_encode(chart)
      url = URI("http://#{host}:19999/api/v1/data?chart=#{encoded_chart}&format=json&after=-1&points=1")

      begin
            response = Net::HTTP.get(url)
            # Forzamos que Rails devuelva un JSON real, no un string plano
            render json: JSON.parse(response)
        rescue => e
            render json: { error: e.message }, status: :service_unavailable
        end
    end

   def logs
  log_path = Rails.root.join("log", "#{Rails.env}.log")
  
  # DEBUG en la terminal de Rails
  puts "🔍 Buscando logs en: #{log_path}"
  
  if File.exist?(log_path)
    # Usamos tail pero nos aseguramos de limpiar caracteres raros que rompen el JSON
    raw_content = `tail -n 100 #{log_path}`
    @logs = raw_content.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
    
    puts "✅ Se leyeron #{@logs.lines.count} líneas"
  else
    @logs = "ERROR: No se encuentra el archivo en #{log_path}"
    puts "❌ Archivo no encontrado"
  end

  render json: { logs: @logs }
end

  end
end