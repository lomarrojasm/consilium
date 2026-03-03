class QuestionnaireMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  def diagnostic_report(questionnaire)
    @questionnaire = questionnaire

    # Verificamos que el email exista antes de intentar enviar
    return logger.error("No se pudo enviar el correo: Cuestionario ##{questionnaire.id} no tiene email.") if @questionnaire.email.blank?
    
    # Generamos el URL seguro usando signed_id (dura 1 mes por defecto)
    @download_url = autodiagnostico_pdf_url(@questionnaire.signed_id)

    mail(
      to: @questionnaire.email,
      bcc: "omar.rojas@ligoconsulting.com",
      subject: "Resultados de tu Diagnóstico Consilium - #{@questionnaire.company_name}"
    )
  end
end