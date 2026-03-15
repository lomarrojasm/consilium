class Project < ApplicationRecord
  include TimelineRecordable # <--- Para Timeline
  belongs_to :client

  belongs_to :user, optional: true

  belongs_to :responsible, class_name: "User", optional: true
  
  has_many :stages, -> { order(position: :asc) }, dependent: :destroy
  has_many :activities, through: :stages
  has_many :project_members, dependent: :destroy
  has_many :users, through: :project_members
  has_many :project_comments, dependent: :destroy
  
  has_many_attached :files

  has_many :comments, class_name: 'ProjectComment', dependent: :destroy

  # Estados del proyecto
  enum :status, { borrador: 0, activo: 1, pausado: 2, finalizado: 3 }

  # Validaciones
  validates :name, :start_date, :end_date, presence: true

  # Agrega esta línea para permitir el checkbox en el formulario
  attr_accessor :include_template


  before_validation :set_default_status

  accepts_nested_attributes_for :stages, allow_destroy: true, reject_if: :all_blank

  # Método para generar etapas (Llamado manualmente desde el controlador)
  def create_default_stages
    default_stages = [
      "Reunión Inicial / Kick-off",
      "Levantamiento de Requerimientos",
      "Diseño y Prototipado",
      "Desarrollo e Implementación",
      "Pruebas y QA",
      "Despliegue y Entrega"
    ]

    default_stages.each_with_index do |stage_name, index|
      stages.create(name: stage_name, position: index + 1)
    end
  end

  # Cálculo de Progreso Real (Barra de Estatus)
  def progress_percentage
    total = activities.count
    return 0 if total.zero?
    
    completed = activities.where(completed: true).count
    ((completed.to_f / total) * 100).round
end

  def status_color
    case status
    when 'activo' then 'success'
    when 'pausado' then 'warning'
    when 'finalizado' then 'primary'
    else 'secondary'
    end
  end

  # Determina si una etapa está "desbloqueada" para la vista del cliente
  def stage_unlocked?(stage)
    # 1. Si la opción secuencial está apagada, todo está desbloqueado
    return true unless sequential_stages?
    
    # 2. La primera etapa siempre está desbloqueada
    return true if stage == stages.first
    
    # 3. Una etapa se desbloquea si la ANTERIOR tiene > 90% de progreso
    previous_stage = stages.where("position < ?", stage.position).last
    previous_stage.present? && previous_stage.progress_percentage > 90
  end

  def blocked_stages
  return [] unless sequential_stages?
  
  stages.select do |stage|
    # Una etapa está bloqueada si no es la primera, no está desbloqueada manualmente
    # y su antecesora no ha llegado al 90%
    !stage_unlocked?(stage) && stage != stages.first
  end
end


private

  def set_default_status
    self.status ||= 'borrador'
  end

end