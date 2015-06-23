class AddRightsStatementToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :rights_statement, :string
  end
end
