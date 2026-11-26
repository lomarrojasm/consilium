class ActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_context

  # --- SEGURIDAD AJUSTADA PARA EL FLUJO CLIENTE/SOPORTE ---
  before_action :authorize_project_member!, only: [
    :edit, :tracking, :toggle_user_approval, :toggle_admin_approval, :update_approval_date,
    :upload_evidence, :destroy_evidence, :update_status
  ]

  before_action :authorize_lider_or_senior!, only: [
    :new, :create, :update, :destroy, :toggle, :destroy_log, :reorder
  ]

  before_action :check_stage_lock_on_activity!, only: [ :update_status, :toggle_user_approval, :update_approval_date, :upload_evidence, :destroy_evidence, :destroy_log ]

  def new
    @activity = @project.activities.build
    if params[:stage_id].present?
      stage = @project.stages.find(params[:stage_id])
      if stage.locked_for?(current_user)
        redirect_to client_project_path(@client, @project), alert: "No puedes añadir tareas a una etapa finalizada." and return
      end
      @activity.stage_id = stage.id
    end
  end

  def create
    stage = @project.stages.find(activity_params[:stage_id])

    if stage.locked_for?(current_user)
      redirect_to client_project_path(@client, @project), alert: "No puedes añadir tareas a una etapa finalizada y bloqueada." and return
    end

    @activity = stage.activities.build(activity_params)
    @activity.user = current_user
    @activity.position = (stage.activities.maximum(:position) || -1) + 1

    if @activity.save
      redirect_to client_project_path(@client, @project), notice: "Actividad creada con éxito."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @activity = @project.activities.find(params[:id])
  end

  def tracking
    @activity = @project.activities.find(params[:id])
    render partial: "activities/activity_modal", locals: { activity: @activity }, layout: false
  end

  def update
    unless current_user.role == "admin"
      params[:activity].delete(:created_at)
    end

    old_created_at = @activity.created_at

    attributes = activity_params
    # El formulario envía solo el día: si no cambió se ignora; si cambió se conserva la hora original
    if attributes[:created_at].present?
      new_day = (Date.parse(attributes[:created_at].to_s) rescue nil)
      if new_day.nil? || new_day == old_created_at.to_date
        attributes.delete(:created_at)
      else
        attributes[:created_at] = old_created_at + (new_day - old_created_at.to_date).to_i.days
      end
    end

    if @activity.update(attributes)
      @activity.shift_history!(old_created_at) if @activity.saved_change_to_created_at?
      @activity.normalize_dates!

      total_cost = (@activity.leader_cost || 0) + (@activity.senior_cost || 0) + (@activity.analyst_cost || 0)
      @activity.update_column(:activity_cost, total_cost)

      redirect_to client_project_path(@client, @project), notice: "Actividad actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @activity.destroy
    redirect_to client_project_path(@client, @project), notice: "Actividad eliminada."
  end

  # PATCH .../activities/reorder
  # Params: activity_id (la movida), stage_id (etapa destino), ids[] (orden final en la etapa destino)
  def reorder
    moved  = @project.activities.find(params[:activity_id])
    target = @project.stages.find(params[:stage_id])
    source = moved.stage
    ids    = Array(params[:ids]).map(&:to_i).uniq
    changed_stage = source.id != target.id

    if source.locked_for?(current_user) || target.locked_for?(current_user)
      return render json: { error: "La etapa está finalizada y bloqueada." }, status: :forbidden
    end

    if moved.admin_approved && moved.user_approved
      return render json: { error: "Una actividad finalizada no se puede mover." }, status: :forbidden
    end

    allowed = target.activities.pluck(:id) | [ moved.id ]
    unless ids.include?(moved.id) && (ids - allowed).empty?
      return render json: { error: "Orden inválido, recarga la página." }, status: :unprocessable_entity
    end

    Activity.transaction do
      if changed_stage
        sync_accrual_stage(moved, source, target)
        moved.update_columns(stage_id: target.id, updated_at: Time.current)
      end

      # Posiciones consecutivas en la etapa destino (las no enviadas quedan al final)
      rest = (allowed - ids).sort_by { |id| target.activities.find_by(id: id)&.position.to_i }
      (ids + rest).each_with_index { |id, i| Activity.where(id: id).update_all(position: i) }

      # Compactar etapa origen
      if changed_stage
        source.activities.reload.each_with_index { |a, i| a.update_columns(position: i) }
      end

      if changed_stage
        TimelineLog.create(
          client: @client, user: current_user, resource: moved, resource_name: moved.name,
          action_type: "update", happened_at: moved.timestamp_for(moved.history_date),
          details: "🔀 Actividad movida de «#{source.name}» a «#{target.name}»: #{moved.name}"
        )
      end
    end

    render json: { ok: true, changed_stage: changed_stage }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Recurso no encontrado." }, status: :not_found
  end

  def destroy_log
    # Buscamos solo el log específico porque @client, @project y @activity
    # ya vienen cargados gracias a set_context
    @log = @activity.activity_logs.find(params[:log_id])
    state_before = stages_state
    @log.destroy

    respond_to do |format|
      format.json { render json: approval_payload(@activity, state_before) }
      format.html { redirect_to client_project_path(@client, @project), notice: "Registro eliminado del historial." }
    end
  end

  # ====================================================================
  # MAGIA 1: Checkbox rápido unificado
  # ====================================================================
  def toggle
    new_completed = !@activity.completed
    updates = { completed: new_completed }

    # Si la desmarcamos, se caen todas las aprobaciones y regresa a pendiente
    if !new_completed
      updates[:status] = "pending"
      updates[:admin_approved] = false
      updates[:user_approved] = false
      updates[:admin_approved_at] = nil
      updates[:user_approved_at] = nil
    else
      updates[:status] = "completed"
    end

    @activity.update(updates)

    respond_to do |format|
      format.html { redirect_to client_project_path(@client, @project), notice: "Estatus actualizado." }
      format.turbo_stream { head :ok }
    end
  end

  def upload_evidence
    state_before = stages_state
    files = uploaded_evidence_files
    fecha_seleccionada = parse_evidence_date(params.dig(:activity, :evidence_date))

    # La fecha debe ser coherente con la de la actividad (hasta 10 días después); si no, se ajusta
    date_adjusted = false
    if files.any? && fecha_seleccionada && !@activity.evidence_date_coherent?(fecha_seleccionada)
      fecha_seleccionada = @activity.coherent_evidence_date.in_time_zone
      date_adjusted = true
    end

    if files.any? && fecha_seleccionada
      # La fecha oficial de ejecución la fija la primera evidencia; las siguientes solo suman archivos.
      # (una fecha oficial anterior fuera de rango se reemplaza por la nueva)
      first_evidence = !@activity.evidences.attached? || !@activity.evidence_date_coherent?(@activity.evidence_uploaded_at)

      stamp = @activity.timestamp_for(fecha_seleccionada)
      @activity.timeline_at = stamp
      previous_ids = @activity.evidences_attachments.pluck(:id)

      @activity.evidences.attach(files)
      @activity.evidences_attachments.reload.where.not(id: previous_ids).update_all(created_at: stamp)

      attrs = { completed: true, user: current_user }
      if first_evidence
        attrs[:completed_day] = fecha_seleccionada.day
        attrs[:evidence_uploaded_at] = stamp
      end
      @activity.update(attrs)

      # Registro en el historial, con la misma fecha seleccionada
      names = files.map(&:original_filename)
      comment = if names.one?
        "📁 Subió la evidencia formal de la actividad: #{names.first}."
      else
        "📁 Subió #{names.size} archivos de evidencia: #{names.join(', ')}."
      end

      log = @activity.activity_logs.create!(user: current_user, status: "pending", comment: comment)
      log.update_columns(created_at: stamp, updated_at: stamp)

      if first_evidence
        @activity.reload.fit_conversation_to_evidence!
        @activity.normalize_dates!   # aprobaciones previas no pueden quedar antes de la evidencia
      end

      notice = names.one? ? "Evidencia cargada y registrada con la fecha seleccionada." : "#{names.size} evidencias cargadas y registradas."
      if date_adjusted
        notice += " La fecha se ajustó al #{fecha_seleccionada.strftime('%d/%m/%Y')} para ser coherente con la fecha de la actividad (máximo #{Activity::EVIDENCE_WINDOW_DAYS} días después)."
      end
      respond_to do |format|
        format.json { render json: approval_payload(@activity, state_before).merge(message: notice) }
        format.html { redirect_to client_project_path(@client, @project, anchor: "activity-row-#{@activity.id}"), notice: notice }
      end
    else
      evidence_failure("Debes adjuntar al menos un archivo y seleccionar una fecha válida.", "activity-row-#{@activity.id}")
    end
  end

  def destroy_evidence
    row = "activity-row-#{@activity.id}"

    unless %w[admin lider].include?(current_project_role)
      return evidence_failure("Solo un administrador o líder del proyecto puede eliminar evidencias.", row)
    end

    if @activity.admin_approved && @activity.user_approved
      return evidence_failure("La actividad ya está finalizada; su evidencia no se puede eliminar.", row)
    end

    # Se busca dentro de los adjuntos de ESTA actividad para no poder borrar archivos ajenos
    attachment = @activity.evidences_attachments.find(params[:attachment_id])
    filename = attachment.filename.to_s
    state_before = stages_state
    stamp = @activity.timestamp_for(@activity.history_date)
    @activity.timeline_at = stamp
    attachment.purge

    # El registro "📁 Subió…" de ese archivo deja de existir; el "🗑️ Eliminó…" queda como historial real.
    @activity.reload.prune_stale_evidence_logs!
    log = @activity.activity_logs.create!(user: current_user, status: "pending", comment: "🗑️ Eliminó la evidencia: #{filename}.")
    log.update_columns(created_at: stamp, updated_at: stamp)

    respond_to do |format|
      format.json { render json: approval_payload(@activity, state_before) }
      format.html { redirect_to client_project_path(@client, @project, anchor: row), notice: "Evidencia eliminada." }
    end
  rescue ActiveRecord::RecordNotFound
    evidence_failure("La evidencia ya no existe.", "activity-row-#{params[:id]}")
  end

  def update_evidence_date
    @activity = Activity.find(params[:id])

    if current_user.role == "admin"
      requested = (params[:evidence_uploaded_at].to_date rescue nil)
      adjusted = requested.present? && !@activity.evidence_date_coherent?(requested)
      requested = @activity.coherent_evidence_date if adjusted

      old_date = @activity.evidence_uploaded_at&.to_date
      stamp = requested && @activity.timestamp_for(requested)
      @activity.timeline_at = stamp
      old_reference = @activity.accrual_reference_date

      if requested.present? && @activity.update(evidence_uploaded_at: stamp, completed_day: requested.to_date.day)
        new_date = requested.to_date
        # Los archivos que mostraban la fecha anterior pasan a la nueva
        @activity.evidences_attachments.select { |a| a.created_at.to_date == old_date }.each { |a| a.update_columns(created_at: stamp) }
        @activity.reload.resync_log_dates!   # el historial refleja la nueva fecha de evidencia
        @activity.activity_logs.reload
        @activity.fit_conversation_to_evidence!
        pushed = @activity.normalize_dates!.any? { |c| c[:label].match?(/aprobación|visto/) }
        @activity.refresh_accrual_date!([ old_reference ])
        flash_extra = adjusted ? " Se ajustó al #{new_date.strftime('%d/%m/%Y')} para ser coherente con la fecha de la actividad (máximo #{Activity::EVIDENCE_WINDOW_DAYS} días después)." : ""

        flash_extra += " Las aprobaciones se movieron para no quedar antes de la evidencia." if pushed

        # Redirigimos usando un "ancla" para que la página baje automáticamente a la fila
        redirect_to client_project_path(@client, @project, anchor: "activity-row-#{@activity.id}"), notice: "Fecha de evidencia actualizada correctamente.#{flash_extra}"
      else
        redirect_to client_project_path(@client, @project, anchor: "activity-row-#{@activity.id}"), alert: "Error al actualizar la fecha. Asegúrate de proporcionar una fecha válida."
      end
    else
      redirect_to client_project_path(@client, @project), alert: "No tienes permisos para modificar fechas de evidencia."
    end
  end

  def update_status
    @activity = @project.activities.find(params[:id])
    new_status = params[:status]
    comment = params[:comment]

    if request.format.json? && comment.to_s.strip.blank?
      return render json: { ok: false, error: "Escribe un comentario de seguimiento." }, status: :unprocessable_entity
    end

    state_before = stages_state
    update_params = { status: new_status }
    update_params[:completed] = [ "approved", "completed" ].include?(new_status)

    # Fecha del seguimiento: la elegida (o la del último movimiento), nunca antes de lo ya registrado
    floor = @activity.history_date
    date, adjusted = params[:days_after].present? ? @activity.requested_date(params[:days_after], floor: floor) : [ floor, false ]
    stamp = @activity.timestamp_for(date)
    @activity.timeline_at = stamp

    # Sin evidencia previa, "completada" toma la fecha de este seguimiento como fecha de ejecución
    if update_params[:completed] && @activity.evidence_uploaded_at.nil?
      update_params[:evidence_uploaded_at] = stamp
      update_params[:completed_day] = stamp.day
    end

    if @activity.update(update_params)
      # Creamos el registro del panel de actividad con la fecha de la actividad
      log = @activity.activity_logs.create!(
        user: current_user,
        status: new_status.to_s,
        comment: comment
      )
      log.update_columns(created_at: stamp, updated_at: stamp)
      @activity.normalize_dates! if update_params[:evidence_uploaded_at]

      files = Array.wrap(params[:attachments]).select { |f| f.respond_to?(:original_filename) }
      log.attachments.attach(files) if files.any?

      message = "Seguimiento registrado"
      message += adjusted_message(date) if adjusted
      respond_to do |format|
        format.json { render json: approval_payload(@activity, state_before).merge(message: message) }
        format.html { redirect_to client_project_path(@client, @project), notice: "#{message}. Estatus actualizado." }
      end
    else
      respond_to do |format|
        format.json { render json: { ok: false, error: "No se pudo actualizar el estatus de la actividad." }, status: :unprocessable_entity }
        format.html { redirect_to client_project_path(@client, @project), alert: "No se pudo actualizar el estatus de la actividad." }
      end
    end
  end

  # ====================================================================
  # MAGIA 2: Aprobación del Cliente unificada
  # ====================================================================
  def toggle_user_approval
    state_before = stages_state
    new_state = !@activity.user_approved

    message = apply_user_approval(@activity, new_state, params[:days_after])

    respond_to do |format|
      format.json { render json: approval_payload(@activity, state_before).merge(message: message) }
      format.html { redirect_back fallback_location: client_project_path(@client, @project), notice: "Aprobación de cliente actualizada." }
    end
  end

  # ====================================================================
  # MAGIA 3: Aprobación del Admin unificada
  # ====================================================================
  def toggle_admin_approval
    if current_user.role == "admin"
      state_before = stages_state
      new_state = !@activity.admin_approved

      message = apply_admin_approval(@activity, new_state, params[:days_after])

      respond_to do |format|
        format.json { render json: approval_payload(@activity, state_before).merge(message: message) }
        format.html { redirect_back fallback_location: client_project_path(@client, @project), notice: "Aprobación administrativa actualizada." }
      end
    else
      deny!("Acceso denegado: Acción exclusiva de la administración de Consilium.", client_project_path(@client, @project))
    end
  end

  # PATCH .../activities/bulk_approve  (solo admin)
  # Params: kind (user | admin), ids[]. Procesa solo las actividades elegibles y reporta el resto.
  #   user  -> aprueba como cliente las que aún no lo están (fecha según cada actividad)
  #   admin -> da el Visto Bueno a las que ya tienen aprobación de cliente y aún no la de admin
  def bulk_approve
    return deny!("Acción exclusiva de la administración de Consilium.", client_project_path(@client, @project)) unless current_user.role == "admin"

    kind = params[:kind].to_s
    return render(json: { ok: false, error: "Acción no válida." }, status: :unprocessable_entity) unless %w[user admin].include?(kind)

    ids = Array(params[:ids]).map(&:to_i).uniq.first(500)
    activities = @project.activities.where(id: ids).includes(:stage).to_a
    state_before = stages_state
    processed = []
    skipped = 0

    Activity.transaction do
      activities.each do |act|
        finalized = act.admin_approved && act.user_approved
        eligible = !finalized && !act.stage.locked_for?(current_user) &&
                   (kind == "user" ? !act.user_approved : (act.user_approved && !act.admin_approved))
        if eligible
          kind == "user" ? apply_user_approval(act, true, nil) : apply_admin_approval(act, true, nil)
          processed << act
        else
          skipped += 1
        end
      end
    end
    skipped += (ids.size - activities.size)

    render json: {
      ok: true, processed: processed.size, skipped: skipped,
      results: processed.map { |act| approval_payload(act, state_before) }
    }
  end

  # PATCH .../activities/clear_conversations  (solo admin)
  # Params: scope (activity | stage | project), target_id (de la actividad o la etapa), mode (conversation | files | full),
  #         preview=1 -> solo cuenta lo que se borraría
  def clear_conversations
    return deny!("Acción exclusiva de la administración de Consilium.", client_project_path(@client, @project)) unless current_user.role == "admin"

    mode = params[:mode].to_s
    return render(json: { ok: false, error: "Modo no válido." }, status: :unprocessable_entity) unless Activity::CLEAR_MODES.include?(mode)

    activities, label =
      case params[:scope].to_s
      when "activity" then act = @project.activities.find(params[:target_id]); [ [ act ], "la actividad «#{act.name.to_s.truncate(60)}»" ]
      when "stage"    then st = @project.stages.find(params[:target_id]);      [ st.activities.to_a, "la etapa «#{st.name}»" ]
      when "project"  then [ @project.activities.to_a, "todo el proyecto «#{@project.name}»" ]
      else return render(json: { ok: false, error: "Alcance no válido." }, status: :unprocessable_entity)
      end

    per_activity = activities.map { |a| [ a, a.clearable_logs(mode) ] }.reject { |_, logs| logs.empty? }
    total = per_activity.sum { |_, logs| logs.size }
    summary = per_activity.first(15).map { |a, logs| { id: a.id, name: a.name.to_s.truncate(70), count: logs.size } }

    if params[:preview].present?
      return render json: { ok: true, preview: true, total: total, activities: per_activity.size, summary: summary, label: label }
    end

    ActivityLog.transaction do
      per_activity.each { |_, logs| logs.each(&:destroy!) }

      if total.positive?
        TimelineLog.create(
          client: @client, user: current_user, resource: @project, resource_name: @project.name,
          action_type: "update", happened_at: Time.current,
          details: "🧹 Se limpiaron #{total} registro(s) de seguimiento (#{mode}) de #{label}"
        )
      end
    end

    render json: { ok: true, total: total, activities: per_activity.size, label: label }
  rescue ActiveRecord::RecordNotFound
    render json: { ok: false, error: "Recurso no encontrado." }, status: :not_found
  end

  # Cambia la fecha de una aprobación ya otorgada (user | admin) sin revocarla.
  def update_approval_date
    kind = params[:kind].to_s
    return deny!("Acción no válida.", client_project_path(@client, @project)) unless %w[user admin].include?(kind)
    return deny!("Acceso denegado.", client_project_path(@client, @project)) if kind == "admin" && current_user.role != "admin"

    unless @activity.public_send("#{kind}_approved")
      return render json: { ok: false, error: "La actividad no tiene esa aprobación." }, status: :unprocessable_entity
    end

    ceiling = @activity.admin_approved_at if kind == "user" && @activity.admin_approved
    date, adjusted = @activity.requested_date(params[:days_after], floor: @activity.approval_floor(kind), ceiling: ceiling)
    old_reference = @activity.accrual_reference_date
    old_date = @activity.public_send("#{kind}_approved_at")

    marker = kind == "admin" ? "Visto Bueno definitivo" : "como cliente"
    log = @activity.activity_logs.where(status: "approved").where("comment LIKE ?", "%#{marker}%").order(:created_at).last

    Activity.transaction do
      new_date = old_date&.to_date == date ? old_date : @activity.timestamp_for(date)
      @activity.update_columns("#{kind}_approved_at": new_date)
      log&.update_columns(created_at: new_date, updated_at: new_date)
      @activity.normalize_dates!   # un Visto Bueno nunca queda antes de la aprobación del cliente
      @activity.refresh_accrual_date!([ old_reference ])
    end

    render json: { ok: true, date: date.strftime("%d/%m/%Y"), message: (adjusted ? "Fecha ajustada" + adjusted_message(date) : nil) }
  end

  def simulate_ai_logs
    @activity = Activity.find(params[:id])
    @project = @activity.stage.project
    @client = @project.client

    # Validamos permisos (solo admin)
    unless current_user.role == "admin"
      redirect_to client_project_path(@client, @project), alert: "No autorizado para usar la IA."
      return
    end

    # Instanciamos y ejecutamos el servicio de IA
    simulator = AiActivitySimulatorService.new(@activity, current_user)

    if simulator.call
      # ÉXITO: Redirigimos al proyecto y pasamos el ID para que tu JS reabra el modal automáticamente
      redirect_to client_project_path(@client, @project, open_activity: @activity.id), notice: "✨ Seguimiento simulado con IA generado exitosamente."
    else
      # FALLO: Redirigimos al proyecto
      redirect_to client_project_path(@client, @project, open_activity: @activity.id), alert: "Hubo un error de comunicación con OpenAI."
    end
  end

  private

  def set_context
    if true_user.role == "admin"
      @client = Client.find(params[:client_id])
    else
      @client = current_user.client
      if params[:client_id].to_i != @client.id
        redirect_to root_path, alert: "Acceso denegado." and return
      end
    end

    @project = @client.projects.find(params[:project_id])
    @activity = @project.activities.find(params[:id]) if params[:id]
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Recurso no encontrado."
  end

  def authorize_project_member!
    return if true_user.role == "admin" || @project.users.include?(current_user)
    deny!("No tienes permiso.", client_path(@client))
  end

  def authorize_lider_or_senior!
    role = current_project_role
    return if true_user.role == "admin" || [ "lider", "senior" ].include?(role)
    deny!("No tienes permisos de edición.", client_project_path(@client, @project))
  end

  def check_stage_lock_on_activity!
    activity = @project.activities.find(params[:id])
    if activity.stage.locked_for?(current_user)
      deny!("Acción no permitida: La etapa está finalizada y bloqueada.", client_project_path(@client, @project))
    end
  end

  # --- Lógica de aprobación compartida (acción individual y aprobación en bloque) ---
  # Ambas devuelven un aviso si la fecha pedida tuvo que ajustarse.
  def apply_user_approval(activity, new_state, days_after)
    stamp, message = approval_stamp(activity, :user, new_state, days_after)
    activity.timeline_at = stamp

    updates = { user_approved: new_state, user_approved_at: new_state ? stamp : nil }

    # Si el cliente retira su aprobación, se cae todo lo demás y se reabre la tarea
    if !new_state
      updates[:admin_approved] = false
      updates[:admin_approved_at] = nil
      updates[:completed] = false
      updates[:status] = "pending"
    end

    activity.update(updates)

    action_text = new_state ? "✅ Aprobó formalmente" : "↩️ Revocó la aprobación de"
    log = activity.activity_logs.create!(
      user: current_user,
      status: (new_state ? "approved" : "pending"),
      comment: "#{action_text} la actividad como cliente."
    )
    log.update_columns(created_at: stamp, updated_at: stamp)
    message
  end

  def apply_admin_approval(activity, new_state, days_after)
    stamp, message = approval_stamp(activity, :admin, new_state, days_after)
    activity.timeline_at = stamp

    updates = { admin_approved: new_state, admin_approved_at: new_state ? stamp : nil }

    # Si el Admin retira el visto bueno, la actividad vuelve a incompleta
    if new_state
      updates[:completed] = true
      updates[:status] = "approved"
    else
      updates[:completed] = false
      updates[:status] = "pending"
    end

    activity.update(updates)

    action_text = new_state ? "🛡️ Otorgó" : "↩️ Retiró"
    log = activity.activity_logs.create!(
      user: current_user,
      status: (new_state ? "approved" : "pending"),
      comment: "#{action_text} el Visto Bueno definitivo (Admin)."
    )
    log.update_columns(created_at: stamp, updated_at: stamp)
    message
  end

  # Fecha y hora de una aprobación o de su revocación, según la regla de la actividad
  def approval_stamp(activity, kind, new_state, days_after)
    adjusted = false
    date =
      if !new_state
        activity.history_date
      elsif days_after.present?
        chosen, adjusted = activity.requested_date(days_after, floor: activity.approval_floor(kind))
        chosen
      else
        activity.coherent_approval_date(kind)
      end

    [ activity.timestamp_for(date), (adjusted ? "Fecha ajustada" + adjusted_message(date) : nil) ]
  end

  def adjusted_message(date)
    " al #{date.strftime('%d/%m/%Y')} para respetar el orden y la ventana de #{Activity::EVIDENCE_WINDOW_DAYS} días"
  end

  # Error al eliminar evidencia: JSON para fetch, redirect para formularios normales
  def evidence_failure(message, row)
    if request.format.json?
      render json: { ok: false, error: message }, status: :unprocessable_entity
    else
      redirect_to client_project_path(@client, @project, anchor: row), alert: message
    end
  end

  # Respuesta de rechazo: JSON para peticiones fetch, redirect para formularios normales.
  def deny!(message, redirect_path)
    if request.format.json?
      render json: { ok: false, error: message }, status: :forbidden
    else
      redirect_to redirect_path, alert: message
    end
  end

  # Foto del estado de bloqueo/desbloqueo de todas las etapas, para saber si una
  # aprobación obliga a refrescar la página completa (etapa terminada o siguiente desbloqueada).
  def stages_state
    @project.stages.reload.map { |st| [ st.id, @project.stage_unlocked?(st), st.locked_for?(current_user) ] }
  end

  # HTML nuevo de la fila y del resumen de la etapa para actualizar la tabla sin recargar.
  def approval_payload(activity, state_before)
    activity = @project.activities.find(activity.id)
    stage = activity.stage
    stage_locked = stage.locked_for?(current_user)
    can_sort = !stage_locked && (current_user.role == "admin" || %w[lider senior].include?(current_project_role))

    {
      ok: true,
      activity_id: activity.id,
      stage_id: stage.id,
      row_html: render_to_string(partial: "projects/activity_row", formats: [ :html ],
                                 locals: { activity: activity, stage: stage, stage_locked: stage_locked, can_sort: can_sort }),
      stats_html: render_to_string(partial: "projects/stage_stats", formats: [ :html ], locals: { stage: stage }),
      reload: stages_state != state_before
    }.tap do |payload|
      # El panel (modal) solo se regenera cuando la petición viene de él
      if params[:with_modal].present?
        payload[:modal_html] = render_to_string(partial: "activities/activity_modal", formats: [ :html ], locals: { activity: activity })
      end
    end
  end

  # El devengo financiero se enlaza por texto (etapa + concepto); al cambiar de etapa
  # se actualiza su stage_name para que no quede huérfano ni se ate a otro devengo.
  def sync_accrual_stage(activity, source, target)
    nombre = activity.name.to_s.strip.downcase
    etapa  = source.name.to_s.strip.downcase
    accrual = @project.financial_accruals.to_a.find do |f|
      f.concept_name.to_s.strip.downcase == nombre && f.stage_name.to_s.strip.downcase == etapa
    end
    accrual&.update_columns(stage_name: target.name.presence || accrual.stage_name)
  end

  def uploaded_evidence_files
    Array.wrap(params.dig(:activity, :evidences)).select { |f| f.respond_to?(:original_filename) }
  end

  def parse_evidence_date(value)
    Time.zone.parse(value.to_s) if value.present?
  rescue ArgumentError
    nil
  end

  def activity_params
    params.require(:activity).permit(
      :name, :description, :document_ref, :stage_id, :month, :week, :completed_day, :area, :completed, :status,
      :created_at, :leader_hours, :leader_rate, :leader_cost, :senior_hours, :senior_rate, :senior_cost,
      :analyst_hours, :analyst_rate, :analyst_cost, :activity_cost, :responsible_id
    )
  end
end
