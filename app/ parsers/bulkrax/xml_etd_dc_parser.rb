# frozen_string_literal: true

module Bulkrax
  class XmlEtdDcParser < XmlParser
    def entry_class
      Bulkrax::XmlEtdDcEntry
    end

    # @todo not yet supported
    def file_set_entry_class; end

    def create_file_sets
      create_objects(['file_set'])
    end

    def create_relationships
      ScheduleRelationshipsJob.set(wait: 5.minutes).perform_later(importer_id: importerexporter.id)
    end

    # need to implement a passthrough as the xml parser doesn't support this yet.
    def create_objects(type_array); end

  end
end
