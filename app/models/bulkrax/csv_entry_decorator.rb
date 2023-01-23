module Bulkrax
  # Override Bulkrax v4.4.0
  #
  # @see https://github.com/samvera-labs/bulkrax/pull/719 Remove override when this PR is part of
  #      this application's Bulkrax.
  module CsvEntryDecorator
    def establish_factory_class
      parser.model_field_mappings.each do |key|
        add_metadata('model', record[key]) if record.key?(key)
      end
    end

    def add_ingested_metadata
      establish_factory_class
      super
    end
  end
end
Bulkrax::CsvEntry.prepend(Bulkrax::CsvEntryDecorator)
