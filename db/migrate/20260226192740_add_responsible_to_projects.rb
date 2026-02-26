class AddResponsibleToProjects < ActiveRecord::Migration[8.0]
  def change
    # Agregamos la columna
    add_column :projects, :responsible_id, :bigint
    
    # Agregamos el índice para que las búsquedas sean rápidas
    add_index :projects, :responsible_id
    
    # Vinculamos la columna con la tabla de usuarios
    add_foreign_key :projects, :users, column: :responsible_id
  end
end