class AddActivityNumberToActivityTemplates < ActiveRecord::Migration[8.0]
  def change
    add_column :activity_templates, :activity_number, :integer
  end
end
