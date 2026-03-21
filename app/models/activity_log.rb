class ActivityLog < ApplicationRecord
  belongs_to :activity
  belongs_to :user

  has_many_attached :attachments # Archivos específicos de este movimiento en el timeline

  # Agregamos exactamente el mismo enum que en Activity
  enum :status, { 
    pending: 'pending', 
    approved: 'approved', 
    rejected: 'rejected', 
    completed: 'completed' 
  }

  
end
