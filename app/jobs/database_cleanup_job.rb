# app/jobs/database_cleanup_job.rb
class DatabaseCleanupJob < ApplicationJob
  queue_as :default

  def perform
    # 1. Limpiar logs de actividades de proyectos (> 30 días)
    # Suponiendo que tu modelo es ActivityLog
    deleted_activity_logs = ActivityLog.where("created_at < ?", 30.days.ago).delete_all
    
    # 2. Limpiar TimelineLogs (historial visual)
    deleted_timeline_logs = TimelineLog.where("happened_at < ?", 30.days.ago).delete_all

    # 3. Limpiar Solid Queue (Trabajos finalizados con éxito)
    # Nota: Solid Queue tiene un comando interno, pero aquí lo forzamos a 30 días
    SolidQueue::Job.finished.where("finished_at < ?", 30.days.ago).delete_all

    Rails.logger.info "[Cleanup] Se eliminaron #{deleted_activity_logs} logs de actividades y #{deleted_timeline_logs} eventos del timeline."
  end
end