# frozen_string_literal: true

class GenericWork < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Ubiquity::UniversalMetadata
  include Ubiquity::SharedMetadata
  include Ubiquity::AllModelsVirtualFields
  include Ubiquity::VersionMetadataModelConcern
  # include Ubiquity::UpdateSharedIndex
  include Ubiquity::FileAvailabilityFaceting
  # include Ubiquity::CachingSingle
  # Adds behaviors for hyrax-doi plugin.
  include Hyrax::DOI::DOIBehavior
  # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
  include Hyrax::DOI::DataCiteDOIBehavior

  validates :title, presence: { message: 'Your work must have a title.' }

  self.indexer = GenericWorkIndexer

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include Hyrax::BasicMetadata
end
