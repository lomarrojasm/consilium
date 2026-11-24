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

    # 2. NO se borra la conversación existente (puede incluir comentarios escritos por personas):
    # la IA la recibe como contexto y continúa a partir de ella. Para empezar de cero, primero
    # se usa "Limpiar conversación".
    @activity.prune_stale_evidence_logs!   # quita registros de evidencia que ya no existen
    @existing_chat = @activity.conversation_logs.sort_by(&:created_at)

    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_ACCESS_TOKEN"))
    team_context = @available_users.map { |u| "- ID: #{u[:id]} | Nombre: #{u[:name]} | Rol: #{u[:role]}" }.join("\n")

    # 3. Revisamos si hay documentos para que la IA los incluya en la historia
    document_context = if @activity.evidences.attached?
      nombres = @activity.evidences.map { |e| "'#{e.filename}'" }.join(", ")
      "ATENCIÓN: Ya existe evidencia final adjunta: #{nombres}. La conversación debe girar en torno a la revisión, corrección o validación de #{@activity.evidences.size > 1 ? 'estos documentos' : 'este documento'}."
    elsif @activity.activity_logs.any? { |log| log.attachments.attached? }
      "ATENCIÓN: Hay archivos previos compartidos en el panel de comentarios. Haz que el equipo discuta sobre ellos."
    else
      "Aún no hay documentos subidos. La conversación debe ser sobre el trabajo en progreso, pidiendo estatus o solicitando que se suba la evidencia."
    end

    # Fechas vigentes de la actividad (la IA no debe inventar ni repetir otras)
    fmt = ->(t) { t&.strftime("%d/%m/%Y") || "sin registrar" }
    dates_context = <<~DATES.strip
      - Fecha de creación de la actividad: #{fmt.call(@activity.created_at)}
      - Fecha de evidencia: #{fmt.call(@activity.evidence_uploaded_at)}
      - Aprobación del cliente: #{fmt.call(@activity.user_approved ? @activity.user_approved_at : nil)}
      - Visto bueno de Consilium: #{fmt.call(@activity.admin_approved ? @activity.admin_approved_at : nil)}
    DATES

    # Conversación ya existente (de personas o de simulaciones previas)
    base_day = @activity.created_at.to_date
    existing_context = if @existing_chat.any?
      lines = @existing_chat.map do |log|
        day = (log.created_at.to_date - base_day).to_i
        "- [día #{day}] #{log.user&.full_name || 'Usuario'}: #{log.comment.to_s.gsub(/\s+/, ' ').strip}"
      end
      <<~CHAT.strip
        COMENTARIOS YA EXISTENTES (no los repitas, no los contradigas y no los modifiques; integra su información y continúa la conversación a partir de ellos, respondiendo o dando seguimiento a lo que dicen):
        #{lines.join("\n")}
      CHAT
    else
      "Aún no hay comentarios en el panel."
    end
    interactions = @existing_chat.any? ? "entre 2 y 4 interacciones NUEVAS" : "entre 3 y 5 interacciones"

    # 4. Prompt ajustado a la fecha de creación
    prompt = <<~PROMPT
      Actúas como el motor de simulación de un ERP corporativo en México.
      Genera un historial de seguimiento (comentarios) realista e interactivo para una actividad de proyecto.

      Contexto:
      - Proyecto: "#{@project.name}"
      - Etapa: "#{@activity.stage.name}"
      - Actividad: "#{@activity.name}"
      - #{document_context}

      Fechas vigentes del registro (solo como referencia para el orden de los hechos):
      #{dates_context}

      #{existing_context}

      Participantes disponibles:
      #{team_context}

      Instrucciones:
      1. Genera EXACTAMENTE #{interactions} cronológicas.
      2. Usa un tono corporativo, profesional y natural (español de negocios de México).
      3. Alterna los roles para simular una conversación real (ej. alguien pide avance, otro responde que está revisando el documento, etc).
      4. IMPORTANTE: En tu respuesta JSON, debes incluir el "user_id" numérico exacto de la lista de participantes.
      6. PROHIBIDO escribir fechas, años, meses o días del calendario dentro de "content" (ej. "15/03/2026", "marzo", "2026"). Las fechas las muestra el sistema; si necesitas referirte al tiempo usa expresiones relativas ("ayer", "esta semana").
      5. TIEMPO: Usa "days_after_creation" para indicar cuántos días después de iniciada la actividad ocurrió el comentario. Deben ser valores enteros ascendentes entre 0 y #{max_conversation_days} (ej. 0, 1, 3, 5). Ningún comentario puede ocurrir después de la fecha de evidencia, si existe.#{@existing_chat.any? ? " Los comentarios nuevos deben ocurrir el mismo día o después del último comentario existente (día #{min_conversation_day})." : ""}

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

  MONTHS = "enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembre|setiembre|octubre|noviembre|diciembre"

  # Red de seguridad: si la IA escribe una fecha en el texto, se elimina para que no
  # contradiga las fechas reales que muestra el sistema.
  def strip_dates(text)
    prep = "(?:(?:para|desde|hasta|a partir de)\\s+)?(?:(?:el|del|al|en|de)\\s+)?"
    text.to_s
        .gsub(/#{prep}\b\d{1,2}\s*[\/\-.]\s*\d{1,2}\s*[\/\-.]\s*\d{2,4}\b/i, "")
        .gsub(/#{prep}\b\d{1,2}\s+de\s+(?:#{MONTHS})(?:\s+(?:de|del)\s+\d{4})?/i, "")
        .gsub(/#{prep}\b(?:#{MONTHS})(?:\s+(?:de|del)\s+\d{4})?\b/i, "")
        .gsub(/#{prep}\b(?:19|20)\d{2}\b/i, "")
        .gsub(/\s+([,.;:])/, '\\1').gsub(/\s{2,}/, " ").strip
  end

  # Día mínimo para comentarios nuevos: el del último comentario existente (si lo hay)
  def min_conversation_day
    return 0 if @existing_chat.blank?
    last = (@existing_chat.map { |l| l.created_at.to_date }.max - @activity.created_at.to_date).to_i
    [ [ last, 0 ].max, max_conversation_days ].min
  end

  # Tope de días de la conversación: hasta la fecha de evidencia (si existe) o la ventana de 10 días
  def max_conversation_days
    if @activity.evidence_uploaded_at
      [ (@activity.evidence_uploaded_at.to_date - @activity.created_at.to_date).to_i, 0 ].max
    else
      Activity::EVIDENCE_WINDOW_DAYS
    end
  end

  def valid_configuration?
    ENV["OPENAI_ACCESS_TOKEN"].present? && @activity.present?
  end

  def create_logs(logs_array)
    # Ordenamos asegurando que la conversación tenga sentido cronológico
    sorted_logs = logs_array.sort_by { |log| log["days_after_creation"].to_i }

    ActiveRecord::Base.transaction do
      sorted_logs.each do |log_data|
        # Calculamos la fecha sumando días a la fecha base de la actividad
        dias = [ [ log_data["days_after_creation"].to_i, min_conversation_day ].max, max_conversation_days ].min
        calculated_date = @activity.created_at + dias.days

        # Creamos el log
        log = @activity.activity_logs.create!(
          user_id: log_data["user_id"],
          comment: strip_dates(log_data["content"]),
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
