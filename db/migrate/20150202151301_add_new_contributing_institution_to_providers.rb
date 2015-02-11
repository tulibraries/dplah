class AddNewContributingInstitutionToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :new_contributing_institution, :string
  end
end
