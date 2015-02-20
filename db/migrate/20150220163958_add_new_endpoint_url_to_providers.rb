class AddNewEndpointUrlToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :new_endpoint_url, :string
  end
end
