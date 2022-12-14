# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
class ImageIndexer < AppIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata
end
