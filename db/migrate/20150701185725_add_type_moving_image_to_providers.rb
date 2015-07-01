class AddTypeMovingImageToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :type_moving_image, :string
  end
end
