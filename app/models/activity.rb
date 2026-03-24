class Activity < ApplicationRecord
  include TimelineRecordable # <--- Para Timeline
  belongs_to :stage
  belongs_to :user, optional: true # optional por si permites que el sistema complete tareas automáticamente
  has_many :activity_logs, dependent: :destroy
  has_many_attached :evidence_files # Para subir archivos de ejemplo/detalles

  # Enumeramos los estados para facilitar la lógica
  enum :status, { pending: 'pending', approved: 'approved', rejected: 'rejected', completed: 'completed' }


  # El responsable de la ejecución
  belongs_to :responsible, class_name: "User", optional: true

  # Esta línea soluciona el error de forma elegante
  delegate :project, to: :stage, allow_nil: true


  # Habilitar adjunto
  has_one_attached :evidence
  
  # Validaciones
  validates :name, presence: true

  # NUEVO: Sincronización automática con Finanzas
  after_save :sync_financial_accrual

  
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
    
    # 2. BÚSQUEDA EXTREMA EN RUBY (A prueba de mayúsculas, minúsculas y espacios invisibles)
    # Extraemos todos los conceptos y los comparamos limpiándolos por completo.
    accrual = project.financial_accruals.to_a.find do |f|
      f.concept_name.to_s.strip.downcase == self.name.to_s.strip.downcase
    end

    # Si por alguna razón no lo encuentra, nos avisará en la terminal negra del servidor
    unless accrual 
      Rails.logger.error "🛑 ALERTA FINANCIERA: No se encontró coincidencia para la actividad '#{self.name}'"
      return 
    end

    # 3. Lógica de completado (Evalúa tanto el checkbox como el estatus de texto)
    estatus_ok = ['approved', 'aprobado', 'completado', 'terminado', 'done', 'listo p/v.b.', 'listo']
    esta_terminada = (self.completed == true) || estatus_ok.include?(self.status.to_s.downcase)

    Rails.logger.info "✅ ÉXITO FINANCIERO: Sincronizando '#{accrual.concept_name}' -> ¿Terminada? #{esta_terminada}"

    # 4. ACTUALIZACIÓN DIRECTA (Escribe directo en la base de datos)
    if esta_terminada
      fecha = accrual.accrued_date || Date.current
      accrual.update_columns(status: 'accrued', accrued_date: fecha)
    else
      accrual.update_columns(status: 'pending', accrued_date: nil)
    end
  end


  private

  # Verifica si realmente cambió el estatus o la casilla de completado
  def status_or_completion_changed?
    saved_change_to_completed? || saved_change_to_status?
  end

  
end