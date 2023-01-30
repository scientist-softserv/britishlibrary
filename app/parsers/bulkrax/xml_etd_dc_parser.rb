# frozen_string_literal: true

module Bulkrax
  class XmlEtdDcParser < XmlParser
    def entry_class
      Bulkrax::XmlEtdDcEntry
    end

    # @note We can remove these when we go to something past Bulkrax v4.4.0 (or at least include SHA c514810d90653905ad6d6809eabe8fcfe7ff02d7)
    # @note this not yet supported yet in bulkrax
    def file_set_entry_class; end

    def create_relationships
      ScheduleRelationshipsJob.set(wait: 5.minutes).perform_later(importer_id: importerexporter.id)
    end

    # @note We can remove these when we go to something past Bulkrax v4.4.0 (or at least include SHA c514810d90653905ad6d6809eabe8fcfe7ff02d7)
    # @todo not yet supported
    def collection_entry_class; end

    # @note We can remove these when we go to something past Bulkrax v4.4.0 (or at least include SHA c514810d90653905ad6d6809eabe8fcfe7ff02d7)
    # @todo not yet supported
    def create_collections; end

    # @note We can remove these when we go to something past Bulkrax v4.4.0 (or at least include SHA c514810d90653905ad6d6809eabe8fcfe7ff02d7)
    # @todo not yet supported
    def create_file_sets; end

    # Override bulkrax v4.4.0 to address bug that is fixed in
    # https://github.com/samvera-labs/bulkrax/pull/713
    #
    # @see # https://github.com/samvera-labs/bulkrax/pull/713
    def create_objects(types = [])
      types.each do |object_type|
        send("create_#{object_type.pluralize}")
      end
    end
  end
end
