class InitialLoadPlanSFunders < ActiveRecord::Migration[5.2]
  def up
    MaintainPlanSFunders.call
  end

  def down
    @updated_funder_dois = []
    PlanSFunder.find_each do |funder|
      funder.update(funder_status: 'inactive')
      @updated_funder_dois << funder.funder_doi
    end
    ReindexFundersJob.perform_later(dois: @updated_funder_dois)
  end
end
