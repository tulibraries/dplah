class AddThumbnailToken1ToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :thumbnail_token_1, :string
  end
end
