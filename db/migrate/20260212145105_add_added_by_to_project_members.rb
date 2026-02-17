class AddAddedByToProjectMembers < ActiveRecord::Migration[8.0]
  def change
    add_reference :project_members, :added_by, null: true, foreign_key: { to_table: :users }
  end
end