module Admin
  class SystemMetricsController < ApplicationController
    before_action :authorize_admin!
    layout "application"

    def index
      # Carga la vista principal
    end

    # 1. Datos para las gráficas (Netdata)
    def chart_data
      chart = params[:chart] || "system.cpu"
      url = "http://74.208.227.22:19999/api/v1/data?chart=#{chart}&after=-300&points=60&format=json"
      
      response = Net::HTTP.get(URI(url))
      render json: JSON.parse(response)
    rescue => e
      render json: { error: e.message }, status: :service_unavailable
    end

    # 2. Visor de Logs con codificación segura
    def logs
      log_path = Rails.root.join("log", "#{Rails.env}.log")
      
      if File.exist?(log_path)
        # Leemos las últimas 200 líneas y forzamos UTF-8 para evitar errores de JSON
        raw_content = `tail -n 200 #{log_path}`
        @logs = raw_content.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      else
        @logs = "--- No se encontró el archivo de log en #{log_path} ---"
      end

      render json: { logs: @logs }
    end

    # 3. Estadísticas de Workers y Listado de Tareas
    def worker_stats
      render json: {
        active_workers: SolidQueue::Process.where(last_heartbeat_at: 5.minutes.ago..).count,
        pending: SolidQueue::Job.where(finished_at: nil).count,
        failed: SolidQueue::FailedExecution.count,
        # Detalles de los últimos 5 fallos
        failed_details: fetch_failed_details,
        # Detalles de las próximas 5 tareas
        pending_details: fetch_pending_details
      }
    end

    # 4. Acción de Reintento Manual
    def retry_failed_jobs
      count = SolidQueue::FailedExecution.count
      SolidQueue::FailedExecution.retry_all
      render json: { status: "success", message: "Se han puesto en cola #{count} tareas para reintento." }
    end

    def discard_all_failed_jobs
        count = SolidQueue::FailedExecution.count
        # Esto elimina los registros de la tabla de fallos definitivamente
        SolidQueue::FailedExecution.discard_all
        
        render json: { status: "success", message: "Se han limpiado #{count} registros de errores." }
    end

    private

    def fetch_failed_details
      SolidQueue::FailedExecution.includes(:job).order(created_at: :desc).limit(5).map do |fe|
        {
          id: fe.job.id,
          class: fe.job.class_name,
          error: fe.error.to_s.truncate(80),
          at: fe.created_at.strftime("%H:%M:%S")
        }
      end
    end

    def fetch_pending_details
      SolidQueue::Job.where(finished_at: nil).order(created_at: :desc).limit(5).map do |job|
        {
          id: job.id,
          class: job.class_name,
          arguments: job.arguments.to_s.truncate(50),
          at: job.created_at.strftime("%H:%M:%S")
        }
      end
    end

    def authorize_admin!
      redirect_to root_path, alert: "No autorizado" unless current_user&.admin?
    end
  end
end