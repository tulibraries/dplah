class AddNewProviderIdPrefixToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :new_provider_id_prefix, :string
  end
end
