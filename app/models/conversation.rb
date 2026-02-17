class Conversation < ApplicationRecord
  include TimelineRecordable # <--- Para Timeline
  belongs_to :client
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  
  has_many :messages, dependent: :destroy

  # Validación para que no se dupliquen chats entre las mismas dos personas en el mismo cliente
  validates :sender_id, uniqueness: { scope: [:recipient_id, :client_id] }

  # Scope para buscar conversaciones donde el usuario participa (ya sea enviando o recibiendo)
  scope :involving, ->(user) {
    where("conversations.sender_id = ? OR conversations.recipient_id = ?", user.id, user.id)
  }

  # Método helper para encontrar la conversación sin importar quién empezó
  def self.between(user1, user2, client)
    where(client: client)
      .where(
        "(conversations.sender_id = :user1 AND conversations.recipient_id = :user2) OR 
         (conversations.sender_id = :user2 AND conversations.recipient_id = :user1)",
        { user1: user1.id, user2: user2.id }
      )
  end
end