require "net/http"

class SystemMetricsController < ApplicationController
  # Protegemos esta ruta para que solo usuarios con sesión iniciada puedan verla
  before_action :authenticate_user!

  def show
    chart = params[:chart]

    # Rails le pide a localhost (127.0.0.1) internamente
    url = URI("http://127.0.0.1:19999/api/v1/data?chart=#{chart}&after=-60&points=1&format=json")

    begin
      response = Net::HTTP.get(url)
      render json: response
    rescue => e
      render json: { error: "No se pudo conectar a Netdata" }, status: 500
    end
  end
end
