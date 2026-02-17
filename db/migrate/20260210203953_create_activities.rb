class CreateActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :activities do |t|
      t.string :name
      t.boolean :completed
      t.references :stage, null: false, foreign_key: true
      t.integer :month
      t.integer :week
      t.string :document_ref
      t.text :description

      t.timestamps
    end
  end
end
