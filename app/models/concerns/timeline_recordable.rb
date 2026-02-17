module TimelineRecordable
  extend ActiveSupport::Concern

  included do
    # 1. MARCAR EL OBJETO COMO 'RECIÉN NACIDO'
    # Usamos after_create (estándar) para poner una bandera en la memoria RAM del objeto
    # antes de que se ejecuten los commits.
    after_create :marcar_como_nuevo

    # 2. DISPARADORES DEL TIMELINE
    after_commit :log_creation, on: :create
    after_commit :log_update, on: :update
    before_destroy :log_destruction
  end

  private

  # Método auxiliar para levantar la bandera
  def marcar_como_nuevo
    @_acabo_de_nacer = true
  end

  # ---------------------------------------------------------
  # 1. LÓGICA DE CREACIÓN
  # ---------------------------------------------------------
  def log_creation
    client_ref = resolve_client
    return unless client_ref

    actor = resolve_actor

    mensaje = case self
              when Project
                "🚀 Nuevo Proyecto iniciado: #{self.name}"
              when Activity
                "📋 Nueva Tarea creada: #{self.name}"
              when Message
                "💬 Mensaje en el chat"
              when ProjectMember
                "👤 Nuevo miembro: #{self.user.try(:first_name)}"
              when ProjectComment
                "📝 Nuevo comentario en #{self.project.name}"
              else
                "✨ Nuevo registro creado: #{self.class.name}"
              end

    TimelineLog.create(
      client: client_ref,
      user: actor,
      resource: self,
      action_type: 'create',
      details: mensaje
    )
  rescue => e
    Rails.logger.error "⚠️ Timeline Create Error: #{e.message}"
  end

  # ---------------------------------------------------------
  # 2. LÓGICA DE ACTUALIZACIÓN
  # ---------------------------------------------------------
  def log_update
    # 1. BLINDAJE POR ID
    return if previous_changes.key?('id')

    # 2. BLINDAJE POR IGUALDAD DE TIEMPO (Vital para que no salga al crear)
    # Si la fecha de actualización es idéntica al nacimiento (mismo segundo), ignoramos.
    return if self.updated_at.to_i == self.created_at.to_i

    # Ignoramos cambios internos
    changes = previous_changes.except('updated_at', 'created_at')
    return if changes.empty?

    client_ref = resolve_client
    return unless client_ref

    # 3. LÓGICA DE ACTIVIDADES (Corregida)
    if self.is_a?(Activity)
        # ACEPTAMOS CUALQUIER CAMBIO A TRUE (nil->true o false->true)
        # Ya estamos protegidos del "create" por el blindaje de tiempo de arriba.
        if previous_changes.key?('completed') && previous_changes['completed'].last == true
            
            nombre_archivo = self.evidence.attached? ? self.evidence.filename.to_s : "sin archivo"
            mensaje = "✅ Tarea completada: #{self.name} (Evidencia: #{nombre_archivo})"
            
            TimelineLog.create(
              client: client_ref,
              user: Current.user || self.try(:user), 
              resource: self,
              action_type: 'update',
              details: mensaje
            )
            return 
        end
    end

    # 4. LÓGICA PARA PROYECTOS
    if self.is_a?(Project) && previous_changes.key?('status')
      mensaje = "🔄 Estado del proyecto cambió a: #{self.status}"
      TimelineLog.create(
        client: client_ref,
        user: Current.user || self.try(:user), 
        resource: self,
        action_type: 'update',
        details: mensaje
      )
      return
    end

    # 5. MENSAJE GENÉRICO
    campos = changes.keys.map { |k| k.humanize }.join(", ")
    mensaje = "✏️ Actualización en #{campos}"

    TimelineLog.create(
      client: client_ref,
      user: Current.user || self.try(:user), 
      resource: self,
      action_type: 'update',
      details: mensaje
    )
  rescue => e
    Rails.logger.error "⚠️ Error en Timeline Update: #{e.message}"
  end

  # ---------------------------------------------------------
  # 3. LÓGICA DE ELIMINACIÓN
  # ---------------------------------------------------------
  def log_destruction
    client_ref = resolve_client
    return unless client_ref

    detalle = case self
              when ProjectMember then "🗑️ Se eliminó al miembro: #{self.user.try(:first_name)}"
              when Activity then "🗑️ Se eliminó la tarea: #{self.name}"
              else "🗑️ Registro eliminado: #{self.class.name}"
              end

    TimelineLog.create(
      client: client_ref,
      user: Current.user, 
      resource_type: self.class.name,
      resource_id: self.id,
      action_type: 'destroy',
      details: detalle,
      happened_at: Time.current
    )
  end

  # Helpers
  def resolve_client
    return self if self.is_a?(Client)
    return self.client if self.respond_to?(:client)
    return self.project&.client if self.respond_to?(:project)
    return self.stage&.project&.client if self.respond_to?(:stage)
    return self.conversation&.client if self.respond_to?(:conversation)
    nil
  end

  def resolve_actor
    if self.respond_to?(:added_by) && self.added_by.present?
      self.added_by
    elsif self.respond_to?(:user) && self.user.present?
      self.user
    else
      Current.user
    end
  end
end