class AddSourceScaleToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :source_scale, :string
  end
end
