class QuestionnaireMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  def diagnostic_report(questionnaire)
    @questionnaire = questionnaire

    # Verificamos que el email exista antes de intentar enviar
    if @questionnaire.email.blank?
      return logger.error("No se pudo enviar el correo: Cuestionario ##{questionnaire.id} no tiene email.") 
    end
    
    # Se corrige el nombre del método a signed_id (sin el prefijo 'to_')
    @download_url = autodiagnostico_pdf_url(id: @questionnaire.signed_id)

    mail(
      from: ENV['MAILER_SENDER'] || 'no-reply@consilium.com',
      to: @questionnaire.email,
      bcc: "omar.rojas@ligoconsulting.com",
      subject: "Resultados de tu Diagnóstico Consilium - #{@questionnaire.company_name}"
    )
  end
end