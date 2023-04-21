# frozen_string_literal: true

namespace :hyku do
  desc "maintain PlanSFunder table"
  task maintain_funders: :environment do
    MaintainPlanSFunders.call
    # funders_to_reindex = MaintainPlanSFunders.call
    # @TODO: This is where we would find all works in each
    # tenant that are using any of the funders returned above,
    # and then reindex each of them.
  end
end
