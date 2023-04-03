class PlanSFunder < ApplicationRecord
  validates_uniqueness_of :funder_doi
end
