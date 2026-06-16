class AiActivitySimulatorService
  def initialize(activity, admin_user)
    @activity = activity
    @admin_user = admin_user
    @project = activity.stage.project

    # 1. Recopilamos a todos los usuarios involucrados
    @available_users = []
    @available_users << { id: @admin_user.id, name: @admin_user.full_name, role: "Consultor / Director" }

    if @activity.responsible.present?
      @available_users << { id: @activity.responsible.id, name: @activity.responsible.full_name, role: "Responsable de la Actividad" }
    end

    @project.users.each do |user|
      @available_users << { id: user.id, name: user.full_name, role: "Miembro del Equipo" }
    end

    @available_users.uniq! { |u| u[:id] }
  end

  def call
    return false unless valid_configuration?

    # 2. Limpiamos el panel antes de generar la nueva simulación
    # Respetamos absolutamente cualquier log que tenga un archivo adjunto o que sea del sistema (emojis)
    clear_previous_simulation

    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_ACCESS_TOKEN"))
    team_context = @available_users.map { |u| "- ID: #{u[:id]} | Nombre: #{u[:name]} | Rol: #{u[:role]}" }.join("\n")

    # 3. Revisamos si hay documentos para que la IA los incluya en la historia
    document_context = if @activity.evidence.attached?
      "ATENCIÓN: Ya existe un documento de evidencia final adjunto llamado '#{@activity.evidence.filename}'. La conversación debe girar en torno a la revisión, corrección o validación de este documento."
    elsif @activity.activity_logs.any? { |log| log.attachments.attached? }
      "ATENCIÓN: Hay archivos previos compartidos en el panel de comentarios. Haz que el equipo discuta sobre ellos."
    else
      "Aún no hay documentos subidos. La conversación debe ser sobre el trabajo en progreso, pidiendo estatus o solicitando que se suba la evidencia."
    end

    # 4. Prompt ajustado a la fecha de creación
    prompt = <<~PROMPT
      Actúas como el motor de simulación de un ERP corporativo en México.
      Genera un historial de seguimiento (comentarios) realista e interactivo para una actividad de proyecto.

      Contexto:
      - Proyecto: "#{@project.name}"
      - Etapa: "#{@activity.stage.name}"
      - Actividad: "#{@activity.name}"
      - #{document_context}

      Participantes disponibles:
      #{team_context}

      Instrucciones:
      1. Genera EXACTAMENTE entre 3 y 5 interacciones cronológicas.
      2. Usa un tono corporativo, profesional y natural (español de negocios de México).
      3. Alterna los roles para simular una conversación real (ej. alguien pide avance, otro responde que está revisando el documento, etc).
      4. IMPORTANTE: En tu respuesta JSON, debes incluir el "user_id" numérico exacto de la lista de participantes.
      5. TIEMPO: Usa "days_after_creation" para indicar cuántos días después de iniciada la actividad ocurrió el comentario. Deben ser valores ascendentes (ej. 0, 1, 3, 5).

      FORMATO DE SALIDA ESTRICTO (JSON):
      {
        "logs": [
          {
            "user_id": 1,
            "content": "Mensaje de seguimiento...",
            "days_after_creation": 2
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
          temperature: 0.75
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

  def clear_previous_simulation
    @activity.activity_logs.find_each do |log|
      # Eliminamos los logs "plásticos" de IA, pero blindamos los que el usuario haya hecho
      is_system_or_official = log.comment.match?(/📁|✅|🛡️|↩️/)
      has_files = log.attachments.attached?

      log.destroy unless is_system_or_official || has_files
    end
  end

  def create_logs(logs_array)
    # Ordenamos asegurando que la conversación tenga sentido cronológico
    sorted_logs = logs_array.sort_by { |log| log["days_after_creation"].to_i }

    ActiveRecord::Base.transaction do
      sorted_logs.each do |log_data|
        # Calculamos la fecha sumando días a la fecha base de la actividad
        dias = log_data["days_after_creation"].to_i
        calculated_date = @activity.created_at + dias.days

        # Creamos el log
        log = @activity.activity_logs.create!(
          user_id: log_data["user_id"],
          comment: log_data["content"],
          status: "pending"
        )

        # Magia de update_columns para forzar la fecha y saltar callbacks de Rails
        log.update_columns(
          created_at: calculated_date,
          updated_at: calculated_date
        )
      end
    end
  end
end
