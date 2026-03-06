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
  end
end