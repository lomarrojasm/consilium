class CreateActivityTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :activity_templates do |t|
      t.references :stage_template, null: false, foreign_key: true
      t.string :name
      t.string :document_ref
      t.string :area
      t.integer :month
      t.integer :week
      t.decimal :leader_rate, precision: 10, scale: 2
      t.decimal :senior_rate, precision: 10, scale: 2
      t.decimal :analyst_rate, precision: 10, scale: 2
      t.decimal :leader_hours, precision: 10, scale: 2
      t.decimal :senior_hours, precision: 10, scale: 2
      t.decimal :analyst_hours, precision: 10, scale: 2

      t.timestamps
    end
  end
end
