class AddInstitutionUrlToSite < ActiveRecord::Migration[5.2]
  def change
    add_column :sites, :institution_url, :string
  end
end
