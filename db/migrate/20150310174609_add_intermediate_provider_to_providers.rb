class AddIntermediateProviderToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :intermediate_provider, :string
  end
end
