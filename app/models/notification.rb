class Notification < ApplicationRecord
  # Quién recibe la notificación (User)
  belongs_to :recipient, polymorphic: true
  # Quién creó la acción (User)
  belongs_to :actor, polymorphic: true
  # Qué objeto es (Message o ProjectComment)
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(10) }
end