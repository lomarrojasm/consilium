# app/jobs/database_cleanup_job.rb
class DatabaseCleanupJob < ApplicationJob
  queue_as :default

  # El historial de las actividades y la línea de tiempo del cliente NUNCA se borran de forma automática:
  # sus fechas son las de la actividad (pueden ser de años anteriores). Solo se limpian
  # los registros técnicos de la cola de trabajos.
  def perform
    # Limpiar Solid Queue (Trabajos finalizados con éxito, > 30 días)
    deleted_jobs = SolidQueue::Job.finished.where("finished_at < ?", 30.days.ago).delete_all

    Rails.logger.info "[Cleanup] Se eliminaron #{deleted_jobs} trabajos finalizados de la cola."
  end
end
