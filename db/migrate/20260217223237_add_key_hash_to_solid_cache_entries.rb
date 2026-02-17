class AddKeyHashToSolidCacheEntries < ActiveRecord::Migration[8.0]
  def change
    # Agregamos las columnas faltantes
    add_column :solid_cache_entries, :key_hash, :integer, limit: 8, null: false, after: :id
    add_column :solid_cache_entries, :byte_size, :integer, limit: 4, null: false, after: :created_at
    
    # Actualizamos los índices
    remove_index :solid_cache_entries, :key if index_exists?(:solid_cache_entries, :key)
    add_index :solid_cache_entries, :key_hash, unique: true
    add_index :solid_cache_entries, [:key_hash, :byte_size]
  end
end