# frozen_string_literal: true

module Bulkrax
  class ArticleCsvParser < CsvParser
    def entry_class
      Bulkrax::ArticleCsvEntry
    end
  end
end
