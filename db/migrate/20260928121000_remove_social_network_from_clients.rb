class RemoveSocialNetworkFromClients < ActiveRecord::Migration[8.0]
  def change
    remove_column :clients, :social_network, :text
  end
end
