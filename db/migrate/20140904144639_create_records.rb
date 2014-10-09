class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.text :content
      t.references :provider, index: true

      t.timestamps
    end
  end
end
