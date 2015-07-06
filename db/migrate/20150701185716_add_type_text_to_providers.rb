class AddTypeTextToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :type_text, :string
  end
end
