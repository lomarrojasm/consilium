class ConversationParticipant < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  def unread_messages_count
    return 0 if last_read_at.nil?
    conversation.messages.where("messaged_at > ?", last_read_at).count
  end
end