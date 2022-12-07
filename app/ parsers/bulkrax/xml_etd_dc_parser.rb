# frozen_string_literal: true

module Bulkrax
  class XmlEtdDcParser < XmlParser
    def entry_class
      Bulkrax::XmlEtdDcEntry
    end

    def create_file_sets
      create_objects(['file_set'])
    end

    def create_relationships
      ScheduleRelationshipsJob.set(wait: 5.minutes).perform_later(importer_id: importerexporter.id)
    end

  end
end
