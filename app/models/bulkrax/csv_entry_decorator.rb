# OVERRIDE Bulkrax 1.0.2 allow collections to happen

module Bulkrax
  module CsvEntryDecorator
    def find_collection(collection_identifier)
      Collection.where(id: collection_identifier).first
    end
  end
end

::Bulkrax::CsvEntry.prepend(Bulkrax::CsvEntryDecorator)
