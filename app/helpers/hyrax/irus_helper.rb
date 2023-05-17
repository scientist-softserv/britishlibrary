# frozen_string_literal: true

module Hyrax
  module IrusHelper
    def oai_identifier(controller, file_set_id)
      "#{CatalogController.blacklight_config.oai[:provider][:record_prefix].call(controller)}:#{work_id_from_file_set_id(file_set_id)}"
    end

    def work_id_from_file_set_id(file_set_id)
      file_set = ActiveFedora::Base.where(id: file_set_id)&.first
      parent_for(file_set)&.id
    end

    def parent_for(file_set)
      file_set.parent || file_set.member_of.find(&:work?)
    end
  end
end
