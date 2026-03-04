class Conversation < ApplicationRecord
  include TimelineRecordable # <--- Para Timeline
  belongs_to :client
  belongs_to :sender, class_name: 'User', optional: true
  belongs_to :recipient, class_name: 'User', optional: true
  
  has_many :messages, dependent: :destroy

  # Nuevas relaciones para grupos
  has_many :conversation_participants, dependent: :destroy
  has_many :users, through: :conversation_participants

  # Validación para que no se dupliquen chats entre las mismas dos personas en el mismo cliente
  validates :sender_id, uniqueness: { scope: [:recipient_id, :client_id] }, unless: :is_group?

  # Scope para buscar conversaciones donde el usuario participa (ya sea enviando o recibiendo)
  scope :involving, ->(user) {
    where("conversations.sender_id = ? OR conversations.recipient_id = ?", user.id, user.id)
  }

  # Método para obtener a todos los miembros de forma uniforme
  def all_members
    if is_group
      users
    else
      [sender, recipient].compact
    end
  end

  # Scope para buscar los chats del usuario
  def self.involving(user)
    left_outer_joins(:conversation_participants)
      .where("conversations.sender_id = :uid OR conversations.recipient_id = :uid OR conversation_participants.user_id = :uid", uid: user.id)
      .distinct
  end

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