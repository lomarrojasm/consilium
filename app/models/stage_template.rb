class StageTemplate < ApplicationRecord
  belongs_to :project_template
  has_many :activity_templates, dependent: :destroy
end
