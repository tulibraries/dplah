class RemoveTypesMappingFromProviders < ActiveRecord::Migration
  def change
    remove_column :providers, :type_mapping, :string
  end
end
