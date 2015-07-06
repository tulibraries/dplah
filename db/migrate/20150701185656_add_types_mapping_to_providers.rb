class AddTypesMappingToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :types_mapping, :string
  end
end
