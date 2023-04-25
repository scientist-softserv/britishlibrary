# frozen_string_literal: true

namespace :hyku do
  desc "maintain PlanSFunder table"
  task maintain_funders: :environment do
    MaintainPlanSFunders.call
  end

  task reset_funders: :environment do
    PlanSFunder.destroy_all
    MaintainPlanSFunders.call
  end
end
