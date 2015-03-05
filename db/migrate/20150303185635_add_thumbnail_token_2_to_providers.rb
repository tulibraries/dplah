class AddThumbnailToken2ToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :thumbnail_token_2, :string
  end
end
