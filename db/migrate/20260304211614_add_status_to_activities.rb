class AddStatusToActivities < ActiveRecord::Migration[8.0]
  def change
    add_column :activities, :status, :string
    add_column :activities, :default, :string
    add_column :activities, :pending, :string
  end
end
