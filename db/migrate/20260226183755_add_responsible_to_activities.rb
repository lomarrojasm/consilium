class AddResponsibleToActivities < ActiveRecord::Migration[8.0]
  def change
    # Agregamos la columna apuntando a la tabla users
    add_column :activities, :responsible_id, :bigint
    add_index :activities, :responsible_id
    
    # Especificamos que la llave foránea es hacia la tabla users
    add_foreign_key :activities, :users, column: :responsible_id
  end
end