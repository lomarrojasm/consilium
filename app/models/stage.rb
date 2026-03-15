class Stage < ApplicationRecord
  include TimelineRecordable # <--- Para Timeline
  belongs_to :project
  has_many :activities, -> { order(week: :asc, id: :asc) }, dependent: :destroy

  # Atributo virtual para recibir la instrucción desde el formulario
  attr_accessor :template_stage_number
  
  # Helper para saber el progreso de la etapa individual
  def progress_percentage
    total = activities.count
    return 0 if total.zero?
    (activities.where(completed: true).count.to_f / total * 100).round
  end


  def finished?
    # Una etapa está terminada si su progreso es 100%
    progress_percentage >= 100
  end

  def locked_for?(user)
    # Está bloqueada si está terminada y el usuario NO es admin
    finished? && user.role != 'admin'
  end

end