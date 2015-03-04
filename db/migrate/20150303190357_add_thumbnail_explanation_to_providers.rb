class AddThumbnailExplanationToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :thumbnail_explanation, :string
  end
end
