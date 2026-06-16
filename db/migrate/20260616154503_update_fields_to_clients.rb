class UpdateFieldsToClients < ActiveRecord::Migration[8.0] # El número puede variar según tu versión de Rails
  def change
    # 1. Agregamos los nuevos campos
    add_column :clients, :start_date, :date
    add_column :clients, :status, :string, default: "Activo" # Le ponemos un valor por defecto útil

    # 2. Modificamos los campos existentes usando "reversible" para proteger la base de datos
    reversible do |dir|
      dir.up do
        # Cuando la migración sube (db:migrate), los convierte a text
        change_column :clients, :corporate_regime, :text
        change_column :clients, :industry, :text
      end

      dir.down do
        # Si alguna vez haces rollback, los regresa a string para no romper nada
        change_column :clients, :corporate_regime, :string
        change_column :clients, :industry, :string
      end
    end
  end
end
