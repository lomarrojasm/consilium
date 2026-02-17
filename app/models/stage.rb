class Stage < ApplicationRecord
  include TimelineRecordable # <--- Para Timeline
  belongs_to :project
  has_many :activities, -> { order(week: :asc, id: :asc) }, dependent: :destroy
  
  # Helper para saber el progreso de la etapa individual
  def progress_percentage
    total = activities.count
    return 0 if total.zero?
    (activities.where(completed: true).count.to_f / total * 100).round
  end
end