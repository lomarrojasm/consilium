class QuestionnaireMailer < ApplicationMailer
  def diagnostic_report(questionnaire)
    @questionnaire = questionnaire
    
    # Generamos el URL seguro usando signed_id (dura 1 mes por defecto)
    @download_url = autodiagnostico_pdf_url(@questionnaire.to_signed_id)

    mail(
      to: @questionnaire.email,
      bcc: "omar.rojas@ligoconsulting.com",
      subject: "Resultados de tu Diagnóstico Consilium - #{@questionnaire.company_name}"
    )
  end
end