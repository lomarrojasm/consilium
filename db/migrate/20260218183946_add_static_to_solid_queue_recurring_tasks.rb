class AddStaticToSolidQueueRecurringTasks < ActiveRecord::Migration[8.0]
  def change
    # Agregamos 'default: true' y 'null: false' para evitar problemas
    add_column :solid_queue_recurring_tasks, :static, :boolean, default: true, null: false
  end
end