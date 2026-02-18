class AddDescriptionToSolidQueueRecurringTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :solid_queue_recurring_tasks, :description, :string
  end
end
