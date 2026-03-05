# Preview all emails at http://localhost:3000/rails/mailers/admin_report_mailer
class AdminReportMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/admin_report_mailer/bottleneck_summary
  def bottleneck_summary
    AdminReportMailer.bottleneck_summary
  end
end
