class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.references :client, null: false, foreign_key: true
      
      # --- CORRIGE ESTAS DOS LÍNEAS ---
      # En lugar de foreign_key: true, usa to_table: :users
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      # -------------------------------

      t.timestamps
    end
  end
end