# frozen_string_literal: true

module Hyrax
  module IrusHelper
    def work_id_from_file_set_id(file_set_id)
      parent_for(ActiveFedora::Base.where(id: file_set_id).first).id
    end

    def parent_for(file_set)
      file_set.parent || file_set.member_of.find(&:work?)
    end
  end
end
