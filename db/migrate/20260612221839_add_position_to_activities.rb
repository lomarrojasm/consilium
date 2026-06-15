class AddPositionToActivities < ActiveRecord::Migration[8.0]
  def change
    add_column :activities, :position, :integer
  end
end
