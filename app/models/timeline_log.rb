class TimelineLog < ApplicationRecord
  belongs_to :client
  belongs_to :user, optional: true
  belongs_to :resource, polymorphic: true

  # Validamos que siempre haya una fecha
  before_create :set_happened_at

  private
  def set_happened_at
    self.happened_at ||= Time.current
  end
end