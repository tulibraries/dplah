class AddTypeImageToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :type_image, :string
  end
end
