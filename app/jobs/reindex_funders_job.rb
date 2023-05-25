# frozen_string_literal: true

class ReindexFundersJob < ApplicationJob
  # @param Array of funder DOIs to reindex
  def perform(dois:)
    count_indexed = 0
    Account.find_each do |account|
      next if account.name == "search"
      account.switch do
        dois.each do |doi|
          # find all ids in this tenant using this doi
          qry = "funder_tesim:\"#{doi}\""
          ids = ActiveFedora::SolrService.query(
            qry,
            fl: ActiveFedora.id_field,
            rows: 100
          ).map { |x| x.fetch(ActiveFedora.id_field) }

          # reindex each work by id
          ids.each do |id|
            begin
              ActiveFedora::Base.find(id)&.update_index
              count_indexed += 1
            rescue => e
              Rails.logger.error("😈😈😈 ERROR: unable to reindex id #{id} in tenant #{account.name}")
              Rails.logger.error("#{e.message}")
              next
            end
          end
        end
      end
    end
    Rails.logger.info("😈😈 reindexed #{count_indexed} works in all tenants")
  end
end
