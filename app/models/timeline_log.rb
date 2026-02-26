class TimelineLog < ApplicationRecord
  belongs_to :client
  belongs_to :user, optional: true
  belongs_to :resource, polymorphic: true, optional: true

  # Validamos que siempre haya una fecha
  before_create :set_happened_at

  def display_resource_name
    resource_name.presence || resource&.try(:name) || "Recurso no disponible"
  end

  private

  
  def set_happened_at
    self.happened_at ||= Time.current
  end
end