class ActivityLog < ApplicationRecord
  belongs_to :activity
  belongs_to :user

  has_many_attached :attachments # Archivos específicos de este movimiento en el timeline
end
