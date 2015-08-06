class AddContributingInstitutionDcFieldToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :contributing_institution_dc_field, :string
  end
end
