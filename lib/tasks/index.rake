namespace :hyku do
  desc 'reindex just the works in the background'
  task reindex_works: :environment do
    Account.find_each do |account|
      puts "=============== #{account.name}============"
      switch!(account)
      Site.instance.available_works.each do |work_type|
        title = "~ #{account.name} - #{work_type}"
        klass = work_type.constantize
        progressbar = ProgressBar.create(total: klass.count, title: title, format: '%t %c of %C %a %B %p%%')
        klass.find_each do |w|
          WorkIndexJob.perform_later(w)
          progressbar.increment
        end
      end
    end
  end
end
