class CreateProspectQuestionnaires < ActiveRecord::Migration[8.0]
  def change
    create_table :prospect_questionnaires do |t|
      t.string :name
      t.string :position
      t.string :company_name
      t.text :social_links
      t.string :website
      t.json :answers # Usaremos JSON para las 30 preguntas para no saturar MySQL con columnas
      t.string :status, default: "Pendiente" # Para seguimiento del admin

      t.timestamps
    end
  end
end