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
  after_commit :sync_financial_accrual, on: [:create, :update]

  
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
    estatus_ok = ['approved', 'aprobado', 'completado', 'terminado', 'done', 'listo p/v.b.', 'listo']
    esta_terminada = (self.completed == true) || estatus_ok.include?(self.status.to_s.downcase)

    # 4. ACTUALIZACIÓN DIRECTA EN FINANZAS
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