class AddResourceNameToTimelineLogs < ActiveRecord::Migration[8.0]
  def change
    add_column :timeline_logs, :resource_name, :string
  end
end
