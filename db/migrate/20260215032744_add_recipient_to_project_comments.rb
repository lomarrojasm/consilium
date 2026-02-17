class AddRecipientToProjectComments < ActiveRecord::Migration[8.0]
  def change
    # null: true es vital para permitir mensajes generales
    add_reference :project_comments, :recipient, null: true, foreign_key: { to_table: :users }
  end
end