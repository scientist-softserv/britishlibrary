# frozen_string_literal: true

class RelationTypeService < Hyrax::QaSelectService
  def initialize(_authority_name = nil)
    super('relation_type')
  end
end
