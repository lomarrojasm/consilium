class CreateBillingAuthorizations < ActiveRecord::Migration[8.0]
  def change
    create_table :billing_authorizations do |t|
      t.references :project, null: false, foreign_key: true
      t.references :authorized_by, foreign_key: { to_table: :users } # Quién le dio clic

      t.integer :status, default: 0 # 0: pending, 1: accepted
      t.datetime :accepted_at

      # Datos de Evidencia Digital
      t.string :ip_address
      t.string :user_agent
      t.text :legal_text_version # Guardamos el texto exacto que leyó

      t.timestamps
    end
  end
end
