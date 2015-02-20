class AddProviderIdPrefixToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :provider_id_prefix, :string
  end
end
