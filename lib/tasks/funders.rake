# frozen_string_literal: true

namespace :hyku do
  desc "maintain PlanSFunder table"
  task maintain_funders: :environment do
    MaintainPlanSFunders.call
  end

  desc "empty and reload PlanSFunder table"
  task reset_funders: :environment do
    PlanSFunder.destroy_all
    MaintainPlanSFunders.call
  end

  desc "deactive PlanSFunders and reindex works"
  task clear_funders: :environment do
    @updated_funder_dois = []
    PlanSFunder.find_each do |funder|
      funder.update(funder_status: 'inactive')
      @updated_funder_dois << funder.funder_doi
    end
    ReindexFundersJob.perform_later(dois: @updated_funder_dois)
  end
end
