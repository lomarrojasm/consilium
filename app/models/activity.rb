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
end