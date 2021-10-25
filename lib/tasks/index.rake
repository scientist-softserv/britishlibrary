namespace :hyku do
  desc 'reindex just the works in the background'
  task reindex_works: :environment do
    Account.where(search_only: false).find_each do |account|
      puts "=============== #{account.name}============"
      next if account.name == 'search'
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
desc 'reindex just the collections in the background'
  task reindex_collections: :environment do
    Account.where(search_only: false).find_each do |account|
      puts "=============== #{account.name}============"
      next if account.name == 'search'
      switch!(account)
      title = "~ #{account.name}"
      progressbar = ProgressBar.create(total: Collection.count, title: title, format: '%t %c of %C %a %B %p%%')
      Collection.find_each do |collection|
        CollectionIndexJob.perform_later(collection.id)
        progressbar.increment
      end
    end
  end
end
