class AddCommonRepositoryTypeToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :common_repository_type, :string
  end
end
