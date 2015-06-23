class AddIdentifierTokenToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :identifier_token, :string
  end
end
