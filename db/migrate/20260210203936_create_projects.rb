class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.integer :status
      t.text :details
      t.date :start_date
      t.date :end_date
      t.decimal :budget
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
