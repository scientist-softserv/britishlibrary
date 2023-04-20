class PlanSFunder < ApplicationRecord
  validates :funder_doi, uniqueness: true
end
