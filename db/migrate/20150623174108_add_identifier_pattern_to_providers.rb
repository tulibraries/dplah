class AddIdentifierPatternToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :identifier_pattern, :string
  end
end
