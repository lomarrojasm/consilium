class PublicQuestionnairesController < ApplicationController
  # Permite acceso público a los formularios
  skip_before_action :authenticate_user!
  
  # Layout por defecto para las vistas públicas
  layout 'public'
  
  # Acceso a las listas de preguntas definidas en el Helper
  helper QuestionnaireHelper

  # --- 1. CUESTIONARIO NARRATIVO ---
  def new
    @questionnaire = ProspectQuestionnaire.new
  end

  def create
    @questionnaire = ProspectQuestionnaire.new(questionnaire_params)
    @questionnaire.status = "Nuevo"
    
    if @questionnaire.save
      redirect_to success_page_path, notice: 'Diagnóstico enviado correctamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # --- NUEVO MÉTODO DE ÉXITO ---
  def exito
    # Simplemente renderizará la vista de agradecimiento
  end

  # --- 2. AUTODIAGNÓSTICO CUANTITATIVO (Gráfica) ---
  def new_autodiagnostico
    @questionnaire = ProspectQuestionnaire.new
  end

  def create_autodiagnostico
    @questionnaire = ProspectQuestionnaire.new(questionnaire_params)
    @questionnaire.status = "Autodiagnóstico"
    
    if @questionnaire.save
      # DISPARO EN SEGUNDO PLANO: Rails lo manda a Solid Queue y libera al usuario
      QuestionnaireMailer.diagnostic_report(@questionnaire).deliver_later
      redirect_to autodiagnostico_exito_path(@questionnaire)
    else
      render :new_autodiagnostico, status: :unprocessable_entity
    end
  end

  def autodiagnostico_exito
    @questionnaire = ProspectQuestionnaire.find(params[:id])
    # Centralizamos el cálculo de scores
    set_scores_from_answers
  end

  # --- 3. GENERACIÓN DE PDF ---
  def download_pdf
    # 1. SEGURIDAD: Usamos find_signed para que nadie pueda adivinar IDs de otros reportes
    # Si prefieres usar IDs normales, cambia a: @questionnaire = ProspectQuestionnaire.find(params[:id])
    @questionnaire = ProspectQuestionnaire.find_signed!(params[:id])
    
    # 2. LÓGICA DE DATOS: Ejecutamos tus métodos para calcular promedios
    set_scores_from_answers 

    # 3. EL FIX PARA EL ERROR NIL: Cargamos las preguntas que la vista intenta recorrer
    # Esto evita el error "undefined method each_with_index for nil"
    @questions = helpers.get_autodiagnostico_questions 

    # 4. RENDERIZADO DEL HTML
    html = render_to_string(
      template: 'public_questionnaires/autodiagnostico_exito',
      layout: 'pdf', 
      formats: [:html]
    )

    # 5. CONFIGURACIÓN DE URL BASE (Para Docker/Producción)
    base_url_for_pdf = Rails.env.production? ? "http://127.0.0.1:80" : request.base_url

    # 6. GENERACIÓN CON GROVER
    grover = Grover.new(html, 
      display_url: base_url_for_pdf,
      wait_until: 'networkidle0',
      print_background: true,
      format: 'A4',
      margin: { top: '1cm', right: '1cm', bottom: '1cm', left: '1cm' },
      viewport: { width: 1024, height: 1400 },
      launch_args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
    )

    pdf = grover.to_pdf

    # 7. ENTREGA DEL ARCHIVO
    send_data pdf, 
              filename: "Reporte_Consilium_#{@questionnaire.company_name.parameterize}.pdf", 
              type: 'application/pdf',
              disposition: 'attachment'

  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to root_path, alert: "El enlace de descarga es inválido o ha expirado."
  rescue => e
    # Captura de errores para depuración
    logger.error "Error generando PDF: #{e.message}"
    logger.error e.backtrace.join("\n")
    redirect_to autodiagnostico_exito_path(@questionnaire), alert: "Hubo un problema al generar el PDF."
  end

  private

  # Método para centralizar la lógica de cálculo y evitar repetir código
  def set_scores_from_answers
    answers = @questionnaire.answers || {}
    @scores = [
      calc_avg(answers, 1..5),   # Dirección y Estrategia
      calc_avg(answers, 6..10),  # Administración y Finanzas
      calc_avg(answers, 11..15), # Operación y Procesos
      calc_avg(answers, 16..20), # Ventas y Mercadotecnia
      calc_avg(answers, 21..25)  # Organización y C. Humano
    ]
  end

  # Calcula el promedio de un rango de respuestas (a1, a2, etc.)
  def calc_avg(answers, range)
    keys = range.map { |i| "a#{i}" }
    values = keys.map { |k| answers[k].to_f }
    
    return 0 if values.empty?
    
    (values.sum / values.size).round(2)
  end

  def questionnaire_params
    # Permitimos campos base y el hash de respuestas answers
    params.require(:prospect_questionnaire).permit(:name, :position, :company_name, :email, :website, :status).tap do |whitelisted|
      if params[:prospect_questionnaire][:answers].present?
        whitelisted[:answers] = params[:prospect_questionnaire][:answers].to_unsafe_h 
      end
    end
  end
end