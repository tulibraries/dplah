class AddInProductionToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :in_production, :string
  end
end
