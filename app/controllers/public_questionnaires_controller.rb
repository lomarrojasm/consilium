class PublicQuestionnairesController < ApplicationController
  # Permite que cualquier persona acceda a los formularios sin loguearse
  skip_before_action :authenticate_user!
  
  # Usa un layout limpio (sin menús de admin)
  layout 'public'
  
  # Incluye el helper para tener acceso a las listas de preguntas
  helper QuestionnaireHelper

  # --- 1. CUESTIONARIO NARRATIVO (Diagnóstico Profundo) ---

  def new
    @questionnaire = ProspectQuestionnaire.new
  end

  def create
    @questionnaire = ProspectQuestionnaire.new(questionnaire_params)
    @questionnaire.status = "Nuevo" # Estado inicial para el Admin
    
    if @questionnaire.save
      # Redirige a una vista de éxito genérica o la que ya tengas configurada
      redirect_to success_page_path, notice: 'Diagnóstico enviado correctamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end


  # --- 2. AUTODIAGNÓSTICO CUANTITATIVO (Gráfica de Telaraña) ---

  def new_autodiagnostico
    @questionnaire = ProspectQuestionnaire.new
  end

  def create_autodiagnostico
    @questionnaire = ProspectQuestionnaire.new(questionnaire_params)
    @questionnaire.status = "Autodiagnóstico"


    puts "------- PARAMS RECIBIDOS -------"
    puts questionnaire_params.inspect
    puts "-------------------------------"
    
    if @questionnaire.save
      # Redirige específicamente a la página de resultados con la gráfica
      redirect_to autodiagnostico_exito_path(@questionnaire)
    else
      render :new_autodiagnostico, status: :unprocessable_entity
    end
  end

  def autodiagnostico_exito
    @questionnaire = ProspectQuestionnaire.find(params[:id])
    answers = @questionnaire.answers || {}

    # Calculamos los promedios por categoría para la gráfica de Radar
    # Los rangos corresponden a las preguntas a1-a5, a6-a10, etc. definidas en el Helper
    @scores = [
      calc_avg(answers, 1..5),   # Dirección y Estrategia
      calc_avg(answers, 6..10),  # Administración y Finanzas
      calc_avg(answers, 11..15), # Operación y Procesos
      calc_avg(answers, 16..20), # Ventas y Mercadotecnia
      calc_avg(answers, 21..25)  # Organización y C. Humano
    ]
  end


  private

  # Método auxiliar para calcular el promedio de un rango de respuestas
  def calc_avg(answers, range)
    keys = range.map { |i| "a#{i}" }
    # Extraemos los valores, los convertimos a float y filtramos ceros si fuera necesario
    values = keys.map { |k| answers[k].to_f }
    
    return 0 if values.empty?
    
    (values.sum / values.size).round(2)
  end

  # Configuración de parámetros permitidos
  def questionnaire_params
    # Permitimos los campos básicos y le decimos a Rails que acepte 
    # cualquier contenido dentro del hash :answers
    params.require(:prospect_questionnaire).permit(:name, :company_name, :website, :status).tap do |whitelisted|
      whitelisted[:answers] = params[:prospect_questionnaire][:answers].to_unsafe_h if params[:prospect_questionnaire][:answers]
    end
  end
end