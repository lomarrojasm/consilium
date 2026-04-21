class AddTemplateIdToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :template_id, :integer
  end
end
