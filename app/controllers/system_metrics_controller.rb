require "net/http"

class SystemMetricsController < ApplicationController
  # Protegemos esta ruta para que solo usuarios con sesión iniciada puedan verla
  before_action :authenticate_user!

  def show
    chart = params[:chart]

    # Usamos la IP real del servidor porque Rails está dentro de un contenedor Docker
    url = URI("http://74.208.227.22:19999/api/v1/data?chart=#{chart}&after=-60&points=1&format=json")

    begin
      response = Net::HTTP.get(url)
      render json: response
    rescue => e
      Rails.logger.error "Error conectando a Netdata: #{e.message}"
      render json: { error: "No se pudo conectar a Netdata" }, status: 500
    end
  end
end
