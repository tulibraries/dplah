class AddThumbnailPatternToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :thumbnail_pattern, :string
  end
end
