class CreateQuotations < ActiveRecord::Migration[8.0]
  def change
    create_table :quotations do |t|
      t.references :project, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.decimal :total_amount
      t.integer :status
      t.datetime :sent_at
      t.datetime :accepted_at
      t.string :ip_address
      t.string :user_agent
      t.text :legal_text
      t.string :auth_code

      t.timestamps
    end
  end
end
