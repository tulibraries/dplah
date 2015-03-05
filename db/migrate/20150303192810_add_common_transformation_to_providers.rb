class AddCommonTransformationToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :common_transformation, :string
  end
end
