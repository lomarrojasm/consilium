class AddMembershipToClients < ActiveRecord::Migration[8.0]
  def change
    # Agregamos el default: 0 para que nadie se quede en "nil"
    add_column :clients, :membership, :integer, default: 0
  end
end