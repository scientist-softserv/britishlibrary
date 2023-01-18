# frozen_string_literal: true

module Bulkrax
  class XmlEtdDcParser < XmlParser
    def entry_class
      Bulkrax::XmlEtdDcEntry
    end

    # @note this not yet supported yet in bulkrax
    def file_set_entry_class; end

    def create_relationships
      ScheduleRelationshipsJob.set(wait: 5.minutes).perform_later(importer_id: importerexporter.id)
    end
  end
end
