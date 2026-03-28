class AddProjectTypeToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :project_type, :string
  end
end
