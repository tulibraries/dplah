class AddNewIntermediateProviderToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :new_intermediate_provider, :string
  end
end
