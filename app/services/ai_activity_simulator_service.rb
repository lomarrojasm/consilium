# app/services/ai_activity_simulator_service.rb
class AiActivitySimulatorService
  def initialize(activity, admin_user)
    @activity = activity
    @admin_user = admin_user
    @project = activity.stage.project

    # 1. Recopilamos a todos los usuarios involucrados para darle opciones a la IA
    @available_users = []

    # Agregamos al Admin/Consultor
    @available_users << { id: @admin_user.id, name: @admin_user.full_name, role: "Consultor / Director" }

    # Agregamos al Responsable de la actividad (si existe)
    if @activity.responsible.present?
      @available_users << { id: @activity.responsible.id, name: @activity.responsible.full_name, role: "Responsable de la Actividad" }
    end

    # Agregamos al resto del equipo asignado al proyecto
    @project.users.each do |user|
      @available_users << { id: user.id, name: user.full_name, role: "Miembro del Equipo" }
    end

    # Eliminamos duplicados por si el admin o responsable ya estaban en la lista del equipo
    @available_users.uniq! { |u| u[:id] }
  end

  def call
    return false unless valid_configuration?

    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_ACCESS_TOKEN"))

    # Convertimos la lista de usuarios a texto para que la IA los conozca
    team_context = @available_users.map { |u| "- ID: #{u[:id]} | Nombre: #{u[:name]} | Rol: #{u[:role]}" }.join("\n")

    # Prompt con ingeniería avanzada para interacción multi-usuario
    prompt = <<~PROMPT
      Actúas como el motor de simulación de un ERP corporativo en México.
      Genera un historial de seguimiento (comentarios) realista e interactivo para una actividad de proyecto.

      Contexto:
      - Proyecto: "#{@project.name}"
      - Etapa: "#{@activity.stage.name}"
      - Actividad: "#{@activity.name}"

      Participantes disponibles en el proyecto (DEBES alternar entre ellos para crear una conversación realista):
      #{team_context}

      Instrucciones:
      1. Genera entre 10 y 15 interacciones cronológicas simulando una conversación sobre el avance de la actividad.
      2. Usa un tono corporativo, profesional y natural (español de negocios de México).
      3. Alterna los roles. Por ejemplo: el 'Consultor' pide estatus, el 'Responsable' responde con avances, otro 'Miembro' comenta que subió un archivo, el 'Consultor' aprueba, etc.
      4. IMPORTANTE: En tu respuesta JSON, debes incluir el "user_id" numérico exacto de la lista de participantes proporcionada.

      FORMATO DE SALIDA ESTRICTO (JSON):
      {
        "logs": [
          {
            "user_id": 1,
            "author_name": "Nombre del participante",
            "content": "Mensaje de seguimiento...",
            "simulated_days_ago": 3
          }
        ]
      }
    PROMPT

    begin
      response = client.chat(
        parameters: {
          model: "gpt-4o-mini",
          response_format: { type: "json_object" },
          messages: [
            { role: "system", content: "Eres un asistente de datos que solo responde en JSON válido." },
            { role: "user", content: prompt }
          ],
          temperature: 0.75 # Un poco más de creatividad para la conversación
        }
      )

      json_response = JSON.parse(response.dig("choices", 0, "message", "content"))
      create_logs(json_response["logs"])
      true
    rescue StandardError => e
      Rails.logger.error("Error en simulación de IA: #{e.message}")
      false
    end
  end

  private

  def valid_configuration?
    ENV["OPENAI_ACCESS_TOKEN"].present? && @activity.present?
  end

  def create_logs(logs_array)
    # Ordenamos los logs cronológicamente del más antiguo al más reciente
    # para que al guardarse en la DB mantengan el flujo lógico de la conversación.
    sorted_logs = logs_array.sort_by { |log| log["simulated_days_ago"].to_i }.reverse

    ActiveRecord::Base.transaction do
      sorted_logs.each do |log_data|
        # Simulamos que los comentarios ocurrieron en el pasado
        created_time = log_data["simulated_days_ago"].to_i.days.ago

        @activity.activity_logs.create!(
          user_id: log_data["user_id"],
          comment: log_data["content"], # Utilizamos el atributo correcto (comment)
          created_at: created_time,
          updated_at: created_time
        )
      end
    end
  end
end
