namespace :doi do
  desc "move single dois to original_doi field"
  task doi_to_original_doi: :environment do
    Account.where(search_only: false).each do |account|
      switch!(account)
      logger = ActiveSupport::Logger.new("log/dois-#{account.name}.log")

      Hyrax.config.curation_concerns.each do |work_type|
        logger.info("====== #{work_type}")

        work_type.find_each do |work|
          begin
            print "."
            next if work.doi.blank?
            logger.info(work.id)
            work.original_doi = work.doi
            work.doi = nil
            work.save!
          rescue StandardError => e
            logger.error("E: #{work.id}\n#{e.message}")
          end
        end
      end
    end
  end
end
