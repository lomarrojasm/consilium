class CreateStageTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :stage_templates do |t|
      t.references :project_template, null: false, foreign_key: true
      t.string :name
      t.integer :position

      t.timestamps
    end
  end
end
