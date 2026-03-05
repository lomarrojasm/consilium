class WeeklyProjectBottleneckJob < ApplicationJob
  queue_as :default

  def perform
    # Enviamos el reporte a los administradores del sistema
    User.where(role: 'admin').each do |admin|
      AdminReportMailer.bottleneck_summary(admin.email).deliver_later
    end
  end
end