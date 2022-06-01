namespace :hyku do
  desc "replaces nil depositor with support@notch8.com"
  task update_depositor: :environment do
    Account.find_each do |account|
      puts "=============== #{account.name} ============"
      next if account.name == "search"
      switch!(account)
      begin
        Site.instance.available_works.each do |work_type|
          title = "~ #{account.name} - #{work_type}"
          klass = work_type.constantize
          progressbar = ProgressBar.create(total: klass.count, title: title, format: "%t %c of %C %a %B %p%%")
          klass.find_each do |w|
            progressbar.increment
            next unless w.depositor.nil?
            w.depositor = "support@notch8.com"
            w.save
          end
        end
      # rubocop:disable Style/RescueStandardError
      rescue => e
        # rubocop:enable Style/RescueStandardError
        puts "(#{e.message})"
      end
    end
  end
end
