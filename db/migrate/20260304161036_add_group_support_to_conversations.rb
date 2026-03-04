class AddGroupSupportToConversations < ActiveRecord::Migration[8.0]
  def change
    add_column :conversations, :is_group, :boolean, default: false
    add_column :conversations, :name, :string
  end
end
