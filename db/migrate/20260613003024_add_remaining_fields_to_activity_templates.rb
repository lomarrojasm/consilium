class AddRemainingFieldsToActivityTemplates < ActiveRecord::Migration[8.0]
  def change
    add_column :activity_templates, :activity_cost, :decimal, precision: 10, scale: 2
    add_column :activity_templates, :user_id, :bigint
    add_column :activity_templates, :responsible_id, :bigint
    add_column :activity_templates, :status, :string
    add_column :activity_templates, :completed, :boolean
  end
end
