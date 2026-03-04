class ChangeSenderAndRecipientNullInConversations < ActiveRecord::Migration[8.0]
  def change
    # Esto elimina la restricción 'NOT NULL' a nivel base de datos
    change_column_null :conversations, :sender_id, true
    change_column_null :conversations, :recipient_id, true
  end
end