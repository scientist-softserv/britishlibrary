# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work ThesisOrDissertation`
class ThesisOrDissertation < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Ubiquity::UniversalMetadata
  include Ubiquity::SharedMetadata
  include Ubiquity::AllModelsVirtualFields
  include Ubiquity::VersionMetadataModelConcern
  # include Ubiquity::UpdateSharedIndex
  include Ubiquity::FileAvailabilityFaceting
  # include ::Ubiquity::CachingSingle

  self.indexer = ThesisOrDissertationIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  self.human_readable_type = 'Thesis Or Dissertation'

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
