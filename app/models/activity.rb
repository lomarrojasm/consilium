class Activity < ApplicationRecord
  include TimelineRecordable # <--- Para Timeline
  belongs_to :stage
  belongs_to :user, optional: true # optional por si permites que el sistema complete tareas automáticamente
  has_many :activity_logs, dependent: :destroy
  has_many_attached :evidence_files # Para subir archivos de ejemplo/detalles

  # Fecha (dentro de la actividad) con la que se registra el cambio en la línea de tiempo del cliente
  attr_accessor :timeline_at

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
    accrual = find_accrual
    # Si definitivamente no existe, abortamos silenciosamente sin romper el sistema
    return unless accrual

    # Lógica de completado (Evalúa checkboxes y estatus de texto)
    estatus_ok = [ "approved", "aprobado", "completado", "terminado", "done", "listo p/v.b.", "listo" ]
    esta_terminada = (self.completed == true) || estatus_ok.include?(self.status.to_s.downcase)

    # ACTUALIZACIÓN DIRECTA EN FINANZAS
    if esta_terminada
      # La fecha sale de la actividad. Una fecha capturada a mano en finanzas se respeta.
      previous = accrual_reference_date(
        admin_at: attribute_before_last_save(:admin_approved_at),
        evidence_at: attribute_before_last_save(:evidence_uploaded_at)
      )
      fecha = accrual.accrued_date
      fecha = accrual_reference_date if fecha.nil? || fecha == previous
      accrual.update_columns(status: "accrued", accrued_date: fecha)
    else
      accrual.update_columns(status: "pending", accrued_date: nil)
    end
  end

  # Devengo enlazado por texto: primero etapa + actividad; si no, solo actividad (desde el final)
  def find_accrual(strict: false)
    return unless stage && stage.project

    etapa  = stage.name.to_s.strip.downcase
    nombre = name.to_s.strip.downcase
    accruals = stage.project.financial_accruals.to_a

    exact = accruals.find do |f|
      f.concept_name.to_s.strip.downcase == nombre && f.stage_name.to_s.strip.downcase == etapa
    end
    return exact if exact || strict

    accruals.reverse.find { |f| f.concept_name.to_s.strip.downcase == nombre }
  end

  # Fecha de devengo: Visto Bueno, si no la evidencia, si no el último movimiento válido de la actividad
  def accrual_reference_date(admin_at: admin_approved_at, evidence_at: evidence_uploaded_at)
    [ admin_at, evidence_at ].compact.find { |d| evidence_date_coherent?(d) }&.to_date || history_date
  end

  # Tras mover fechas sin callbacks: actualiza el devengo solo si su fecha era automática
  def refresh_accrual_date!(automatic_dates)
    accrual = find_accrual(strict: true)
    return unless accrual && accrual.status == "accrued"

    current = accrual.accrued_date
    target = accrual_reference_date
    return if current == target

    automatic = current.nil? || automatic_dates.compact.map(&:to_date).include?(current)
    return unless automatic

    accrual.update_columns(accrued_date: target)
    { label: "devengo", from: current, to: target }
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
      stamp = timestamp_for(date.to_date)
      changes << { log_id: log.id, label: label, from: log.created_at, to: stamp }
      log.update_columns(created_at: stamp, updated_at: stamp) unless dry_run
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

  # Cuando cambia la fecha de la actividad, desplaza los mismos días todo lo que pertenecía a su ventana:
  # historial, evidencia, aprobaciones, archivos, línea de tiempo y devengo.
  def shift_history!(old_created_at)
    days = (created_at.to_date - old_created_at.to_date).to_i
    return if days.zero?

    old_window = old_created_at.to_date..(old_created_at.to_date + EVIDENCE_WINDOW_DAYS)
    inside = ->(date) { date.present? && old_window.cover?(date.to_date) }
    old_reference = [ admin_approved_at, evidence_uploaded_at ].find { |d| inside.(d) }

    dates = %i[evidence_uploaded_at user_approved_at admin_approved_at].filter_map do |attr|
      value = self[attr]
      [ attr, value + days.days ] if inside.(value)
    end.to_h
    dates[:completed_day] = dates[:evidence_uploaded_at].day if dates[:evidence_uploaded_at]
    update_columns(dates) if dates.any?

    (activity_logs.reload.to_a + evidences_attachments.reload.to_a).each do |record|
      next unless inside.(record.created_at)
      attrs = { created_at: record.created_at + days.days }
      attrs[:updated_at] = attrs[:created_at] if record.has_attribute?(:updated_at)
      record.update_columns(attrs)
    end

    timeline_events.each do |event|
      event.update_columns(happened_at: event.happened_at + days.days) if inside.(event.happened_at)
    end

    refresh_accrual_date!([ old_reference ])
  end

  def timeline_events
    TimelineLog.where(resource_type: "Activity", resource_id: id)
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
      update_columns(evidence_uploaded_at: timestamp_for(new_date), completed_day: new_date.day)
      resync_log_dates!
      activity_logs.reload
      fit_conversation_to_evidence!
    end
    change
  end

  # ===========================================================================
  # Regla única de fechas:
  #   actividad <= conversación <= evidencia <= aprobación cliente <= Visto Bueno,
  #   todo entre el día de la actividad y EVIDENCE_WINDOW_DAYS días después.
  # ===========================================================================

  # Último movimiento válido (dentro de la ventana); como mínimo, el día de la actividad
  def history_date
    dates = [ evidence_uploaded_at,
              (user_approved_at if user_approved),
              (admin_approved_at if admin_approved) ]
    dates += activity_logs.pluck(:created_at)
    dates.compact.map(&:to_date).select { |d| evidence_date_window.cover?(d) }.max || evidence_date_window.begin
  end

  # Fecha más temprana permitida para una aprobación (kind: :user | :admin)
  def approval_floor(kind)
    previous = [ evidence_date_coherent?(evidence_uploaded_at) ? evidence_uploaded_at.to_date : last_conversation_date ]
    previous << user_approved_at.to_date if kind.to_sym == :admin && user_approved && evidence_date_coherent?(user_approved_at)
    previous.compact.max || evidence_date_window.begin
  end

  # Aprobación automática: un día después del paso anterior, sin pasar de hoy ni de la ventana
  def coherent_approval_date(kind)
    floor = approval_floor(kind)
    candidate = [ floor + 1, evidence_date_window.end ].min
    candidate = [ Date.current, floor ].max if candidate > Date.current && Date.current >= evidence_date_window.begin
    candidate
  end

  # Fecha pedida a mano (días después de la actividad), ajustada a la ventana y al orden.
  # Devuelve [fecha, ajustada?]
  def requested_date(days_after, floor:, ceiling: nil)
    requested = evidence_date_window.begin + days_after.to_i
    date = [ [ requested, floor ].max, evidence_date_window.end ].min
    date = ceiling.to_date if ceiling && evidence_date_coherent?(ceiling) && ceiling.to_date >= floor && date > ceiling.to_date
    [ date, date != requested ]
  end

  # Fecha y hora para un movimiento de ese día, siempre posterior a lo ya registrado ese día
  def timestamp_for(date)
    date = date.to_date
    day = date.in_time_zone.all_day
    taken = [ activity_logs.where(created_at: day).maximum(:created_at) ]
    taken += [ evidence_uploaded_at, user_approved_at, admin_approved_at ].select { |t| t && day.cover?(t) }
    last = taken.compact.max
    return [ last.in_time_zone + 1.second, day.end ].min if last

    noon = date.in_time_zone.change(hour: 12)
    date == created_at.to_date ? [ noon, created_at ].max : noon
  end

  # Lleva a la regla cualquier fecha fuera de la ventana o fuera de orden.
  # Devuelve la lista de cambios [{ label:, from:, to: }].
  def normalize_dates!
    activity_logs.reload
    old_sources = [ evidence_uploaded_at, user_approved_at, admin_approved_at, updated_at ] +
                  activity_logs.map(&:created_at) + timeline_events.pluck(:created_at)
    changes = []

    if (fix = normalize_evidence_date!)
      changes << fix.merge(label: "evidencia")
    end

    previous = evidence_date_coherent?(evidence_uploaded_at) ? evidence_uploaded_at.to_date : nil
    { user: "aprobación cliente", admin: "visto bueno admin" }.each do |kind, label|
      next unless public_send("#{kind}_approved")

      value = public_send("#{kind}_approved_at")
      unless evidence_date_coherent?(value) && (previous.nil? || value.to_date >= previous)
        stamp = timestamp_for(coherent_approval_date(kind))
        changes << { label: label, from: value, to: stamp }
        update_columns("#{kind}_approved_at": stamp)
      end
      previous = public_send("#{kind}_approved_at").to_date
    end

    changes.concat(resync_log_dates!)
    changes.concat(normalize_log_dates!)
    changes.concat(normalize_attachment_dates!)
    changes.concat(normalize_timeline_dates!)
    accrual_change = refresh_accrual_date!(old_sources)
    changes << accrual_change if accrual_change
    changes
  end

  # Registros del historial que siguen fuera de la ventana (conserva su orden relativo)
  def normalize_log_dates!
    window = evidence_date_window
    floor = window.begin
    activity_logs.reload.sort_by { |l| [ l.created_at, l.id ] }.filter_map do |log|
      day = log.created_at.to_date
      if window.cover?(day)
        floor = [ floor, day ].max
        next
      end

      target = day < window.begin ? window.begin : [ floor, history_date ].max
      stamp = timestamp_for(target)
      from = log.created_at
      log.update_columns(created_at: stamp, updated_at: stamp)
      { label: "historial ##{log.id}", from: from, to: stamp }
    end
  end

  # Cada archivo de evidencia muestra una fecha de la actividad
  def normalize_attachment_dates!
    evidences_attachments.reload.filter_map do |attachment|
      next if evidence_date_coherent?(attachment.created_at)

      from = attachment.created_at
      stamp = evidence_date_coherent?(evidence_uploaded_at) ? evidence_uploaded_at : timestamp_for(history_date)
      attachment.update_columns(created_at: stamp)
      { label: "archivo #{attachment.filename}", from: from, to: stamp }
    end
  end

  # La línea de tiempo del cliente usa fechas de la actividad (created_at conserva el momento real)
  def normalize_timeline_dates!
    timeline_events.to_a.filter_map do |event|
      next if evidence_date_coherent?(event.happened_at)

      from = event.happened_at
      stamp = event.action_type == "create" ? created_at : timestamp_for(history_date)
      event.update_columns(happened_at: stamp)
      { label: "línea de tiempo ##{event.id}", from: from, to: stamp }
    end
  end

  def last_conversation_date
    conversation_logs.map { |l| l.created_at.to_date }.select { |d| evidence_date_window.cover?(d) }.max
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
