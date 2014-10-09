class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string :name
      t.text :description
      t.string :endpoint_url
      t.string :metadata_prefix
      t.string :set

      t.timestamps
    end
  end
end
