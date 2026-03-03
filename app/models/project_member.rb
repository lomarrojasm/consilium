class ProjectMember < ApplicationRecord
  include TimelineRecordable # <--- Para Timeline
  belongs_to :project
  belongs_to :user
  belongs_to :added_by, class_name: 'User', optional: true # El usuario que hizo la acción
  # Evita duplicados en el mismo proyecto
  validates :user_id, uniqueness: { scope: :project_id, message: "ya es parte del equipo" }
  
  # Roles internos del proyecto (opcional, pero útil para costos)
  enum :role, { lider: 'Líder', senior: 'Senior', analista: 'Analista', espectador: 'Espectador' }, default: 'espectador'
end