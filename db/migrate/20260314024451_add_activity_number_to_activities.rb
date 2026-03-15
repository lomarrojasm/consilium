class AddActivityNumberToActivities < ActiveRecord::Migration[8.0]
  def change
    add_column :activities, :activity_number, :integer
  end
end
