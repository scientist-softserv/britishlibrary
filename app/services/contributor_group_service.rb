# frozen_string_literal: true

class ContributorGroupService < Hyrax::QaSelectService
  def initialize(_authority_name = nil)
    super('contributor_group')
  end

  #   def self.label(id)
  #     self.class.authority.find(id).fetch('term')
  #   end
end
