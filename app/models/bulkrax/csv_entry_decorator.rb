module Bulkrax
  # Override Bulkrax v5.1.0
  module CsvEntryDecorator
    # NOTE: Remove this once https://github.com/samvera-labs/bulkrax/pull/756 is merged
    def build_object(key, value)
      return unless hyrax_record.respond_to?(value['object'])

      super(key, value)
    end

    # NOTE: Remove this once https://github.com/samvera-labs/bulkrax/pull/756 is merged
    def build_value(key, value)
      return unless hyrax_record.respond_to?(key.to_s)

      super(key, value)
    end

    # Without this hack, when we export a FileSet, it skips exporting the FileSet's creator.  This
    # is because we are overloading the `creator` in the parser.  With this change, the complex
    # `creator` object for works will export correctly (e.g. have the constituent field parts in the
    # CSV).  And the FileSet will have a `creator` column.
    #
    # @note There is almost certainly a round-trip issue remaining in that if we import the once
    #       exported CSV, we need to account for the `creator` attribute discrepencies.  Which, at
    #       this point may be irreconcilable unless we have an override parser for FileSets.
    #
    # @see https://github.com/scientist-softserv/britishlibrary/issues/289
    def fetch_field_mapping
      field_mappings = super

      return field_mappings if importer?
      return field_mappings unless hyrax_record.is_a?(FileSet)

      field_mappings.merge("creator" => { from: "creator" })
    end
  end
end
Bulkrax::CsvEntry.prepend(Bulkrax::CsvEntryDecorator)

# NOTE: Remove this module once https://github.com/samvera-labs/bulkrax/pull/756 is merged
module CsvParserDecorator
  def total
    @total =
      if importer?
        importer.parser_fields['total'] || 0
      elsif exporter?
        limit.to_i.zero? ? current_records_for_export.count : limit.to_i
      else
        0
      end

    return @total
  rescue StandardError
    @total = 0
  end

  def write_files
    require 'open-uri'
    folder_count = 0
    # TODO: This is not performant as well; unclear how to address, but lower priority as of
    #       <2023-02-21 Tue>.
    sorted_entries = sort_entries(importerexporter.entries.uniq(&:identifier))
                     .select { |e| valid_entry_types.include?(e.type) }

    group_size = limit.to_i.zero? ? total : limit.to_i
    sorted_entries[0..group_size].in_groups_of(records_split_count, false) do |group|
      folder_count += 1

      CSV.open(setup_export_file(folder_count), "w", headers: export_headers, write_headers: true) do |csv|
        group.each do |entry|
          csv << entry.parsed_metadata
          next if importerexporter.metadata_only? || entry.type == 'Bulkrax::CsvCollectionEntry'

          store_files(entry.identifier, folder_count.to_s)
        end
      end
    end
  end
end
Bulkrax::CsvParser.prepend(CsvParserDecorator)
