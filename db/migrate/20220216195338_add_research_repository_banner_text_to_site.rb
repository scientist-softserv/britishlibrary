class AddResearchRepositoryBannerTextToSite < ActiveRecord::Migration[5.2]
  def change
      add_column :sites, :research_repository_text, :string
  end
end
