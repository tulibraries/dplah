class AddTypePhysicalObjectToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :type_physical_object, :string
  end
end
