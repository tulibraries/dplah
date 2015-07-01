class AddTypeSoundToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :type_sound, :string
  end
end
