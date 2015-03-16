class AddNewEmailToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :new_email, :string
  end
end
