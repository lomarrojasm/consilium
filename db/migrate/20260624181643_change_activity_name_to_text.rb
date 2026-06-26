class ChangeActivityNameToText < ActiveRecord::Migration[7.1] # El número de versión puede variar según tu Rails
  def up
    # Cambiamos a text para permitir longitud ilimitada
    change_column :activity_templates, :name, :text
    change_column :activities, :name, :text
  end

  def down
    # Por si alguna vez necesitas revertir la migración
    change_column :activity_templates, :name, :string
    change_column :activities, :name, :string
  end
end
