namespace :hyku do
  desc "standardize dates"
  task standardize_dates: :environment do
    Account.find_each do |account|
      switch!(account)
      puts ">>>>>>>>>> Switched to: #{account.cname} <<<<<<<<<<"
      Hyrax.config.curation_concerns.each do |cc|
        puts ">>>>>>>>>> Standardizing dates for all #{cc} work types <<<<<<<<<<"
        cc.find_each do |work|
          work.standardize_dates
        end
      end
    rescue
      puts ">>>>>>>>>> Failed to update account #{account.cname} <<<<<<<<<<"
      next
    end
  end
end
