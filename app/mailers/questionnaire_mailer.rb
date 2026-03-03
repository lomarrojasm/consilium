class QuestionnaireMailer < ApplicationMailer
end
class QuestionnaireMailer < ApplicationMailer
  def diagnostic_report(questionnaire)
    @questionnaire = questionnaire
    @company_name = @questionnaire.company_name

    # Generamos el PDF usando la misma lógica que en el controlador
    # Nota: Aquí usamos un helper para renderizar el HTML desde el Mailer
    pdf_html = ActionController::Base.new.render_to_string(
      template: 'public_questionnaires/autodiagnostico_exito',
      layout: 'pdf',
      locals: { :"@questionnaire" => @questionnaire },
      formats: [:html]
    )

    # Configuramos Grover para generar el PDF en el Job
    # IMPORTANTE: En background jobs, request.base_url no existe. 
    # Usamos la IP interna de Docker tal como lo configuramos antes.
    grover = Grover.new(pdf_html, 
      display_url: "http://127.0.0.1:80",
      wait_until: 'networkidle0',
      print_background: true,
      launch_args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
    )

    attachments["Reporte_Consilium_#{@company_name.parameterize}.pdf"] = grover.to_pdf

    mail(
      to: @questionnaire.email, # Asegúrate de que tu modelo tenga el campo :email
      bcc: "omar.rojas@ligoconsulting.com"
      subject: "Tu Diagnóstico Empresarial Consilium - #{@company_name}"
    )
  end
end