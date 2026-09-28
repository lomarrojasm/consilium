class AddSocialLinksToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :linkedin_url, :string
    add_column :clients, :facebook_url, :string
    add_column :clients, :instagram_url, :string
    add_column :clients, :x_url, :string
    add_column :clients, :youtube_url, :string
  end
end
