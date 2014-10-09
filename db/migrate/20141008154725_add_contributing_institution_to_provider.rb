class AddContributingInstitutionToProvider < ActiveRecord::Migration
  def change
    add_column :providers, :contributing_institution, :string
  end
end
