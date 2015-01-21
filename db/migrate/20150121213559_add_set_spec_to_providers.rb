class AddSetSpecToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :set_spec, :string
  end
end
