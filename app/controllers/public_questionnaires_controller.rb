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
    @questionnaire = ProspectQuestionnaire.find(params[:id])
    set_scores_from_answers

    html = render_to_string(
      template: 'public_questionnaires/autodiagnostico_exito',
      layout: 'pdf', 
      formats: [:html]
    )

    grover = Grover.new(html, 
      display_url: base_url_for_pdf,
      wait_until: 'networkidle0',
      print_background: true,
      format: 'A4',
      margin: { top: '1cm', right: '1cm', bottom: '1cm', left: '1cm' },
      # El viewport obliga a Bootstrap a usar el diseño de escritorio (side-by-side)
      viewport: { width: 1024, height: 1400 },
      launch_args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage'] 
    )

    pdf = grover.to_pdf

    send_data pdf, 
              filename: "Reporte_Consilium_#{@questionnaire.company_name.parameterize}.pdf", 
              type: 'application/pdf',
              disposition: 'attachment'
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
    params.require(:prospect_questionnaire).permit(:name, :company_name, :website, :status).tap do |whitelisted|
      if params[:prospect_questionnaire][:answers].present?
        whitelisted[:answers] = params[:prospect_questionnaire][:answers].to_unsafe_h 
      end
    end
  end
end