class AddDcmiMappingsToProvider < ActiveRecord::Migration
  def change
    add_column :providers, :dcmi_mappings, :boolean
  end
end
