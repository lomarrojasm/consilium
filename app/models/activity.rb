class Activity < ApplicationRecord
  include TimelineRecordable # <--- Para Timeline
  belongs_to :stage
  belongs_to :user, optional: true # optional por si permites que el sistema complete tareas automáticamente
  has_many :activity_logs, dependent: :destroy
  has_many_attached :evidence_files # Para subir archivos de ejemplo/detalles

  # Enumeramos los estados para facilitar la lógica
  enum :status, { pending: "pending", approved: "approved", rejected: "rejected", completed: "completed" }


  # El responsable de la ejecución
  belongs_to :responsible, class_name: "User", optional: true

  # Esta línea soluciona el error de forma elegante
  delegate :project, to: :stage, allow_nil: true


  # Evidencias formales de la actividad (puede haber más de un archivo)
  has_many_attached :evidences

  def evidence_attached?
    evidences.attached?
  end

  # Validaciones
  validates :name, presence: true

  # NUEVO: Sincronización automática con Finanzas
  after_commit :sync_financial_accrual, on: [ :create, :update ]

  after_save :sync_financial_status, if: -> { saved_change_to_admin_approved? || saved_change_to_user_approved? }


  # Opcional: Validar que el área sea una de las permitidas
  validates :area, inclusion: {
    in: %w[Integral Dirección Finanzas Procesos Comercial RH],
    message: "%{value} no es un área válida"
  }, allow_nil: true

  # Método útil: Si en el futuro quieres recalcular el costo basado en horas * tarifa
  def calculate_real_cost
    (leader_hours.to_f * leader_rate.to_f) +
    (senior_hours.to_f * senior_rate.to_f) +
    (analyst_hours.to_f * analyst_rate.to_f)
  end

  # Actualiza el módulo de facturación
  def sync_financial_accrual
    # 1. Aseguramos que tenga proyecto
    return unless self.stage && self.stage.project
    project = self.stage.project

    # 2. MATCH PERFECTO (Etapa + Actividad)
    # Limpiamos los nombres para evitar errores de espacios o mayúsculas
    nombre_etapa_real = self.stage.name.to_s.strip.downcase
    nombre_actividad_real = self.name.to_s.strip.downcase

    # Buscamos que coincida EXACTAMENTE la actividad dentro de su respectiva etapa
    accrual = project.financial_accruals.to_a.find do |f|
      (f.concept_name.to_s.strip.downcase == nombre_actividad_real) &&
      (f.stage_name.to_s.strip.downcase == nombre_etapa_real)
    end

    # PLAN B (Seguridad): Si por alguna razón la etapa no tenía nombre y se guardó como "Etapa 3",
    # buscamos solo por actividad, pero empezando desde el final (reverse) para atrapar las últimas etapas.
    accrual ||= project.financial_accruals.to_a.reverse.find do |f|
      f.concept_name.to_s.strip.downcase == nombre_actividad_real
    end

    # Si definitivamente no existe, abortamos silenciosamente sin romper el sistema
    return unless accrual

    # 3. Lógica de completado (Evalúa checkboxes y estatus de texto)
    estatus_ok = [ "approved", "aprobado", "completado", "terminado", "done", "listo p/v.b.", "listo" ]
    esta_terminada = (self.completed == true) || estatus_ok.include?(self.status.to_s.downcase)

    # 4. ACTUALIZACIÓN DIRECTA EN FINANZAS
    if esta_terminada
      fecha = accrual.accrued_date || Date.current
      accrual.update_columns(status: "accrued", accrued_date: fecha)
    else
      accrual.update_columns(status: "pending", accrued_date: nil)
    end
  end


  # ===========================================================================
  # Coherencia del historial (activity_logs) con los datos vigentes de la actividad
  # ===========================================================================
  SYSTEM_LOG_MARKERS = /📁|✅|🛡️|↩️|🗑️/

  def evidence_logs
    activity_logs.where("comment LIKE ?", "%📁%")
  end

  # Quita de los registros "📁 Subió…" los archivos que ya no existen como evidencia.
  # Si un registro se queda sin archivos, se elimina. Devuelve la lista de cambios.
  def prune_stale_evidence_logs!(dry_run: false)
    current = evidences_attachments.map { |a| a.filename.to_s }
    changes = []

    evidence_logs.order(:created_at).each do |log|
      # Solo registros con el formato automático: "…: archivo(s)."
      match = log.comment.match(/\A📁 Subió (?:la evidencia formal de la actividad|(\d+) archivos de evidencia): (.+)\.\z/m)
      next unless match

      declared = (match[1] || 1).to_i
      surviving = current.select { |name| match[2].include?(name) }
      next if surviving.size >= declared

      if surviving.empty?
        changes << { action: :destroy, log_id: log.id, from: log.comment }
        log.destroy unless dry_run
      else
        new_comment = if surviving.one?
          "📁 Subió la evidencia formal de la actividad: #{surviving.first}."
        else
          "📁 Subió #{surviving.size} archivos de evidencia: #{surviving.join(', ')}."
        end
        changes << { action: :rewrite, log_id: log.id, from: log.comment, to: new_comment }
        log.update_columns(comment: new_comment) unless dry_run
      end
    end

    changes
  end

  # Alinea las fechas del historial con las fechas vigentes de la actividad:
  # - el primer registro de evidencia -> evidence_uploaded_at
  # - último registro de aprobación de cliente / admin -> user_approved_at / admin_approved_at
  def resync_log_dates!(dry_run: false)
    changes = []
    align = lambda do |log, date, label|
      next if log.nil? || date.nil? || log.created_at.to_date == date.to_date
      changes << { log_id: log.id, label: label, from: log.created_at, to: date }
      log.update_columns(created_at: date, updated_at: date) unless dry_run
    end

    align.call(evidence_logs.order(:created_at).first, evidence_uploaded_at, "evidencia") if evidence_uploaded_at

    if user_approved && user_approved_at
      align.call(activity_logs.where("comment LIKE ?", "%Aprobó formalmente%").order(:created_at).last, user_approved_at, "aprobación cliente")
    end
    if admin_approved && admin_approved_at
      align.call(activity_logs.where("comment LIKE ?", "%Otorgó el Visto Bueno%").order(:created_at).last, admin_approved_at, "visto bueno admin")
    end

    changes
  end

  # Desplaza los comentarios simulados/libres (sin emoji de sistema ni adjuntos) cuando
  # cambia la fecha de creación de la actividad, para conservar su separación en días.
  def shift_simulated_logs!(delta_seconds)
    return if delta_seconds.to_i.zero?
    activity_logs.find_each do |log|
      next if log.comment.to_s.match?(SYSTEM_LOG_MARKERS) || log.attachments.attached?
      shifted = log.created_at + delta_seconds
      log.update_columns(created_at: shifted, updated_at: shifted)
    end
  end


  # ===========================================================================
  # Fecha de evidencia coherente con la fecha de la actividad
  # ===========================================================================
  EVIDENCE_WINDOW_DAYS = 10

  # Rango válido: desde la fecha de la actividad hasta 10 días después
  def evidence_date_window
    start = created_at.to_date
    start..(start + EVIDENCE_WINDOW_DAYS)
  end

  def evidence_date_coherent?(date)
    date.present? && evidence_date_window.cover?(date.to_date)
  end

  # Valor sugerido sin consultas (para precargar el modal): el día siguiente a la actividad, sin pasar de hoy
  def default_evidence_date
    window = evidence_date_window
    [ [ window.begin + 1, Date.current ].min, window.begin ].max
  end

  # Fecha coherente calculada con el historial: el día después del último comentario de la conversación
  def coherent_evidence_date
    window = evidence_date_window
    last_chat = conversation_logs.map { |l| l.created_at.to_date }.max
    candidate = (last_chat || window.begin) + 1
    candidate = [ [ candidate, window.begin ].max, window.end ].min
    candidate = Date.current if candidate > Date.current && Date.current >= window.begin
    candidate
  end

  # Comentarios de conversación (simulados o escritos), sin registros de sistema ni adjuntos
  def conversation_logs
    activity_logs.reject { |l| l.comment.to_s.match?(SYSTEM_LOG_MARKERS) || l.attachments.attached? }
  end

  # Reacomoda la conversación entre la fecha de la actividad y la de evidencia
  # (sin llamar a la IA): ningún comentario queda antes de la actividad ni después de la evidencia.
  def fit_conversation_to_evidence!
    return unless evidence_uploaded_at

    base = created_at.to_date
    limit = [ (evidence_uploaded_at.to_date - base).to_i, 0 ].max
    logs = conversation_logs
    return if logs.empty?

    offsets = logs.map { |l| (l.created_at.to_date - base).to_i }
    max = offsets.max

    logs.each_with_index do |log, i|
      day = [ offsets[i], 0 ].max
      day = (day * limit.to_f / max).floor if max > limit && max.positive?
      day = [ [ day, limit ].min, 0 ].max
      next if day == offsets[i]

      moved = log.created_at + (day - offsets[i]).days
      log.update_columns(created_at: moved, updated_at: moved)
    end
  end

  # Reparación: si la fecha de evidencia está fuera del rango, la lleva a una fecha coherente
  def normalize_evidence_date!(dry_run: false)
    return nil unless evidence_uploaded_at && !evidence_date_coherent?(evidence_uploaded_at)

    new_date = coherent_evidence_date
    change = { from: evidence_uploaded_at, to: new_date }
    unless dry_run
      update_columns(evidence_uploaded_at: new_date.in_time_zone, completed_day: new_date.day)
      reload
      resync_log_dates!
      fit_conversation_to_evidence!
    end
    change
  end

  # ===========================================================================
  # Limpieza de conversaciones
  # ===========================================================================
  CLEAR_MODES = %w[conversation files full].freeze

  # Registros que se borrarían según el modo:
  #   conversation -> comentarios sin emoji de sistema y sin adjuntos
  #   files        -> además los comentarios con archivos adjuntos (sin tocar registros de sistema)
  #   full         -> todo el historial (incluye evidencia y aprobaciones registradas)
  def clearable_logs(mode)
    activity_logs.includes(:user).select do |log|
      system = log.comment.to_s.match?(SYSTEM_LOG_MARKERS)
      files = log.attachments.attached?
      case mode.to_s
      when "conversation" then !system && !files
      when "files" then !system
      when "full" then true
      else false
      end
    end
  end

  private

  # Verifica si realmente cambió el estatus o la casilla de completado
  def status_or_completion_changed?
    saved_change_to_completed? || saved_change_to_status?
  end

  def sync_financial_status
    # Buscamos el devengo financiero asociado a esta actividad
    accrual = project.financial_accruals.find_by(concept_name: self.name) # O usa tu llave foránea si tienes activity_id en financial_accrual

    if admin_approved && user_approved
      # 1. Marcamos la actividad como 100% terminada
      update_column(:completed, true)

      # 2. Liberamos el dinero en Finanzas (Devengado)
      accrual&.update(status: "accrued")
    else
      # Si por error desmarcan la tarea, la regresamos a pendiente
      update_column(:completed, false)
      accrual&.update(status: "pending")
    end
  end
end
