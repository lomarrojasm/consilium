class AddPositionToActivityTemplates < ActiveRecord::Migration[8.0]
  def change
    add_column :activity_templates, :position, :integer
  end
end
