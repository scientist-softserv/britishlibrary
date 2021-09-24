namespace :hyku do
  desc "standarize dates"
  task standardize_dates: :environment do
    Account.find_each do |account|
      switch!(account)
      Hyrax.config.curation_concerns.each do |cc|
        cc.find_each do |work|
          work.standardize_dates
        end
      end
    end
  end

end
