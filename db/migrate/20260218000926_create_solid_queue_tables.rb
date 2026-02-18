class CreateSolidQueueTables < ActiveRecord::Migration[8.0]
  def change
    create_table :solid_queue_jobs do |t|
      t.string :queue_name, null: false
      t.string :class_name, null: false, index: true
      t.text :arguments
      t.integer :priority, default: 0, null: false
      t.string :active_job_id, index: true
      t.datetime :scheduled_at
      t.datetime :finished_at, index: true
      t.string :concurrency_key
      t.timestamps
      t.index [ :queue_name, :finished_at ], name: "index_solid_queue_jobs_for_filtering"
      t.index [ :scheduled_at, :finished_at ], name: "index_solid_queue_jobs_for_alerting"
    end

    create_table :solid_queue_recurring_tasks do |t|
      t.string :key, null: false, index: { unique: true }
      t.string :schedule, null: false
      t.string :command, limit: 2048
      t.string :class_name
      t.text :arguments
      t.string :queue_name
      t.integer :priority, default: 0
      t.datetime :last_enqueued_at
      t.timestamps
    end

    # Tablas de ejecución
    [ :scheduled_executions, :ready_executions, :claimed_executions, :failed_executions, :blocked_executions ].each do |table|
      create_table :"solid_queue_#{table}" do |t|
        t.references :job, null: false, index: { unique: true }, foreign_key: { to_table: :solid_queue_jobs, on_delete: :cascade }
        t.timestamps
        t.datetime :expires_at, index: true if table == :claimed_executions
      end
    end

    create_table :solid_queue_pauses do |t|
      t.string :queue_name, null: false, index: { unique: true }
      t.timestamps
    end

    create_table :solid_queue_processes do |t|
      t.string :kind, null: false, index: true
      t.datetime :last_heartbeat_at, null: false, index: true
      t.references :supervisor, index: true
      t.integer :pid, null: false
      t.string :hostname
      t.text :metadata
      t.timestamps
    end

    create_table :solid_queue_semaphores do |t|
      t.string :key, null: false, index: { unique: true }
      t.integer :value, default: 1, null: false
      t.datetime :expires_at, null: false, index: true
      t.timestamps
    end
  end
end