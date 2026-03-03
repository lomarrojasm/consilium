# app/mailers/questionnaire_mailer.rb
class QuestionnaireMailer < ApplicationMailer
  def diagnostic_report(questionnaire)
    # 1. Definimos las variables de instancia (son las que lee la vista)
    @questionnaire = questionnaire
    @company_name = @questionnaire.company_name

    # 2. Renderizamos el HTML usando el contexto del Mailer
    # Esto busca el archivo en app/views/public_questionnaires/autodiagnostico_exito.html.erb
    pdf_html = render_to_string(
      template: 'public_questionnaires/autodiagnostico_exito',
      layout: 'pdf',
      formats: [:html]
    )

    # 3. Configuramos Grover para generar el PDF
    # Usamos la IP interna que configuramos para producción
    grover = Grover.new(pdf_html, 
      display_url: Rails.env.production? ? "http://127.0.0.1:80" : "http://localhost:3000",
      wait_until: 'networkidle0',
      print_background: true,
      launch_args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
    )

    # 4. Adjuntamos el archivo
    attachments["Reporte_Consilium_#{@company_name.parameterize}.pdf"] = grover.to_pdf

    # 5. Enviamos con BCC (asegúrate de incluir la coma al final de cada línea)
    mail(
      to: @questionnaire.email,
      bcc: "omar.rojas@ligoconsulting.com",
      subject: "Tu Diagnóstico Empresarial Consilium - #{@company_name}"
    )
  end
end