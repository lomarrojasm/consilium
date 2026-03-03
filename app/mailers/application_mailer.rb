class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAILER_SENDER', 'notificaciones@consiliumconsultoria.com')
  layout "mailer"
end
