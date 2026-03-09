class PublicQuestionnairesController < ApplicationController
  # Permite acceso público a los formularios
  skip_before_action :authenticate_user!, raise: false
  
  # Layout por defecto para las vistas públicas (Evita errores de current_user)
  layout 'public'
  
  # Acceso a las listas de preguntas definidas en el Helper
  helper QuestionnaireHelper

  # ==========================================
  # 1. CUESTIONARIO NARRATIVO (CONTEXTO)
  # ==========================================
  def new
    @questionnaire = ProspectQuestionnaire.new
  end

  def create
    @questionnaire = ProspectQuestionnaire.new(questionnaire_params)
    
    # Respetamos el estatus si viene del formulario oculto (Ej: Evaluación Membresía)
    @questionnaire.status = "Nuevo" if @questionnaire.status.blank?
    
    if @questionnaire.save
      if @questionnaire.status == 'Evaluación Membresía'
        # Dispara correo automático al prospecto con su link de resultados
        ProspectMailer.membership_result(@questionnaire).deliver_later
        redirect_to success_page_path, notice: "¡Evaluación completada! Revisa tu correo (#{@questionnaire.email}) para ver el resultado."
      else
        # Flujo narrativo original
        redirect_to success_page_path, notice: 'Diagnóstico enviado correctamente.'
      end
    else
      # Renderizamos la vista correspondiente según el tipo de formulario que falló
      target_view = (@questionnaire.status == 'Evaluación Membresía' ? :new_membership : :new)
      render target_view, status: :unprocessable_entity
    end
  end

  # Vista de agradecimiento general
  def exito; end

  # ==========================================
  # 2. AUTODIAGNÓSTICO CUANTITATIVO (GRÁFICA)
  # ==========================================
  def new_autodiagnostico
    @questionnaire = ProspectQuestionnaire.new
  end

  def create_autodiagnostico
    @questionnaire = ProspectQuestionnaire.new(questionnaire_params)
    @questionnaire.status = "Autodiagnóstico"
    
    if @questionnaire.save
      # Dispara reporte de diagnóstico (Gráfica Radar)
      QuestionnaireMailer.diagnostic_report(@questionnaire).deliver_later
      redirect_to autodiagnostico_exito_path(@questionnaire)
    else
      render :new_autodiagnostico, status: :unprocessable_entity
    end
  end

  def autodiagnostico_exito
    @questionnaire = ProspectQuestionnaire.find(params[:id])
    set_scores_from_answers
  end

  # Generación de PDF para Autodiagnóstico (Botón Rojo)
  def download_pdf
    @questionnaire = ProspectQuestionnaire.find_signed!(params[:id])
    set_scores_from_answers 
    @questions = view_context.get_autodiagnostico_questions 

    generate_and_send_pdf(
      template: 'public_questionnaires/autodiagnostico_exito',
      filename: "Reporte_Madurez_#{@questionnaire.company_name.parameterize}.pdf"
    )
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to root_path, alert: "El enlace de descarga es inválido o ha expirado."
  rescue => e
    logger.error "Error PDF Autodiagnóstico: #{e.message}"
    redirect_to root_path, alert: "Hubo un problema al generar el PDF."
  end

  # ==========================================
  # 3. EVALUACIÓN DE MEMBRESÍA
  # ==========================================
  def new_membership
    @questionnaire = ProspectQuestionnaire.new
  end

  # Vista Web del resultado (La que abre el prospecto desde su correo)
  def membership_result
    @questionnaire = ProspectQuestionnaire.find_signed!(params[:id])
    calculate_membership_data
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to root_path, alert: "El enlace es inválido o ha expirado."
  end

  # Acción dedicada para descargar el PDF de Membresía (Botón Dorado)
  def download_membership_pdf
    @questionnaire = ProspectQuestionnaire.find_signed!(params[:id])
    calculate_membership_data
    
    generate_and_send_pdf(
      template: 'public_questionnaires/membership_result',
      filename: "Recomendacion_Membresia_#{@questionnaire.company_name.parameterize}.pdf"
    )
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to root_path, alert: "ID inválido o expirado."
  rescue => e
    logger.error "Error PDF Membresía: #{e.message}"
    redirect_to root_path, alert: "Error al generar el PDF de membresía."
  end

  private

  # ==========================================
  # MÉTODOS PRIVADOS Y DE CÁLCULO
  # ==========================================

  # Motor de generación Grover unificado
  def generate_and_send_pdf(template:, filename:)
    html = render_to_string(template: template, layout: 'pdf', formats: [:html])
    
    # URL base para cargar CSS y Assets correctamente
    base_url = Rails.env.production? ? "http://127.0.0.1:80" : request.base_url

    grover = Grover.new(html, 
      display_url: base_url,
      wait_until: 'networkidle0',
      print_background: true,
      format: 'A4',
      margin: { top: '1cm', right: '1cm', bottom: '1cm', left: '1cm' },
      viewport: { width: 1024, height: 1400 },
      launch_args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
    )

    send_data grover.to_pdf, 
              filename: filename, 
              type: 'application/pdf', 
              disposition: 'attachment'
  end

  # Lógica para determinar el plan sugerido y la justificación
  def calculate_membership_data
    answers = @questionnaire.answers || {}
    @total_score = answers.select { |k, _| k.to_s.start_with?('m') }.values.map(&:to_i).sum
    # Usamos view_context para acceder al helper desde el controlador
    @membership_level = view_context.get_membership_level(@total_score)
    
    @justification = case @membership_level
                     when "Platinum"
                       "Tu empresa maneja múltiples frentes operativos o alta exigencia técnica. Requiere acompañamiento nivel Consejo Directivo."
                     when "Gold"
                       "Fase de delegación y desarrollo de mandos medios. Ideal para optimizar procesos interdepartamentales."
                     else
                       "Fase de cimentación. Enfoque en estandarización básica y control operativo inicial."
                     end
  end

  # Lógica para procesar promedios de la gráfica de Radar
  def set_scores_from_answers
    answers = @questionnaire.answers || {}
    @scores = [
      calc_avg(answers, 1..5),   # Dirección
      calc_avg(answers, 6..10),  # Finanzas
      calc_avg(answers, 11..15), # Operación
      calc_avg(answers, 16..20), # Ventas
      calc_avg(answers, 21..25)  # Organización
    ]
  end

  def calc_avg(answers, range)
    keys = range.map { |i| "a#{i}" }
    values = keys.map { |k| answers[k].to_f }
    return 0 if values.empty?
    (values.sum / values.size).round(2)
  end

  def questionnaire_params
    params.require(:prospect_questionnaire).permit(:name, :position, :company_name, :email, :website, :status).tap do |whitelisted|
      if params[:prospect_questionnaire][:answers].present?
        whitelisted[:answers] = params[:prospect_questionnaire][:answers].to_unsafe_h 
      end
    end
  end
end