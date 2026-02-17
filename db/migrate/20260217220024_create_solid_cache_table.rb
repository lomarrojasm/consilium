class CreateSolidCacheTable < ActiveRecord::Migration[8.0]
  def change
    create_table :solid_cache_entries, id: :bigint do |t|
      t.binary   :key,        null: false, limit: 1024
      t.binary   :value,      null: false, limit: 512.megabytes
      t.datetime :created_at, null: false

      t.index    :key,        unique: true
    end
  end
end