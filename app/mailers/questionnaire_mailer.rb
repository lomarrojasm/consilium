class QuestionnaireMailer < ApplicationMailer
  # Permite que el Mailer entienda las rutas de tu aplicación (ej. new_autodiagnostico_url)
  include Rails.application.routes.url_helpers

  def diagnostic_report(questionnaire)
    @questionnaire = questionnaire
    @company_name = @questionnaire.company_name

    # 1. Renderizamos el HTML usando el contexto de ApplicationController.
    # Esto inyecta automáticamente los helpers de rutas y evita el error de "nil"
    # al pasar las variables a través de 'assigns'.
    pdf_html = ApplicationController.render(
      template: 'public_questionnaires/autodiagnostico_exito',
      layout: 'pdf',
      assigns: { 
        questionnaire: @questionnaire, 
        company_name: @company_name 
      }
    )

    # 2. Configuración de Grover para generar el PDF
    # display_url: 127.0.0.1:80 es vital para que Docker encuentre el CSS internamente
    grover = Grover.new(pdf_html, 
      display_url: Rails.env.production? ? "http://127.0.0.1:80" : "http://localhost:3000",
      wait_until: 'networkidle0',
      print_background: true,
      launch_args: [
        '--no-sandbox', 
        '--disable-setuid-sandbox', 
        '--disable-dev-shm-usage'
      ]
    )

    # 3. Adjuntamos el PDF generado
    attachments["Reporte_Consilium_#{@company_name.parameterize}.pdf"] = grover.to_pdf

    # 4. Enviamos el correo
    # Asegúrate de que las comas al final de cada línea estén presentes
    mail(
      to: @questionnaire.email,
      bcc: "omar.rojas@ligoconsulting.com",
      subject: "Tu Diagnóstico Empresarial Consilium - #{@company_name}"
    )
  end
end