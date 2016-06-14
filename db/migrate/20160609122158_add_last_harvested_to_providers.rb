class AddLastHarvestedToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :last_harvested, :string
  end
end
