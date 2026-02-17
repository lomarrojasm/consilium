class CreateTimelineLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :timeline_logs do |t|
      t.references :client, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :resource, polymorphic: true, null: false
      t.string :action_type
      t.text :details
      t.datetime :happened_at

      t.timestamps
    end
  end
end
