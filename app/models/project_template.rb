class ProjectTemplate < ApplicationRecord
  has_many :stage_templates, -> { order(:position) }, dependent: :destroy
  validates :name, presence: true
end
