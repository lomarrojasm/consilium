class AdminReportMailer < ApplicationMailer
  def bottleneck_summary(admin_email)
    # Buscamos proyectos activos que tengan al menos una etapa bloqueada
    @projects_with_bottlenecks = Project.activo.select { |p| p.blocked_stages.any? }

    mail(
      to: admin_email,
      subject: "⚠️ Reporte Semanal: Cuellos de Botella en Proyectos - #{Time.current.strftime('%d/%m/%Y')}"
    )
  end
end