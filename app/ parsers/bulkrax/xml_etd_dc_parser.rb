# frozen_string_literal: true

module Bulkrax
  class XmlEtdDcParser < XmlParser
    def entry_class
      Bulkrax::XmlEtdDcEntry
    end

    # @this not yet supported yet in bulkrax
    def file_set_entry_class; end

    def create_file_sets
      create_objects(['file_set'])
    end

    def create_relationships
      ScheduleRelationshipsJob.set(wait: 5.minutes).perform_later(importer_id: importerexporter.id)
    end

    # needed to implement a passthrough as the xml parser doesn't support this yet in bulkrax.
    def create_objects(type_array)
      if type_array.include? 'collection'
        create_works
      end
      if type_array.include? 'work'
        create_collections
      end
      if type_array.include? 'relationship'
        create_relationships
      end
    end
  end
end
