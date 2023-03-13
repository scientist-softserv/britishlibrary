# frozen_string_literal: true

class GenericWork < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Ubiquity::UniversalMetadata
  include Ubiquity::SharedMetadata
  include Ubiquity::AllModelsVirtualFields
  include Ubiquity::WorksVirtualFields
  include Ubiquity::VersionMetadataModelConcern
  # include Ubiquity::UpdateSharedIndex
  include Ubiquity::FileAvailabilityFaceting
  # include Ubiquity::CachingSingle
  # Adds behaviors for hyrax-doi plugin.
  include Hyrax::DOI::DOIBehavior
  # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
  include Hyrax::DOI::DataCiteDOIBehavior
  include IiifPrint.model_configuration(
    pdf_split_child_model: self,
    pdf_splitter_service: IiifPrint::SplitPdfs::PagesToJpgsSplitter,
    derivative_service_plugins: [
      IiifPrint::JP2DerivativeService,
      IiifPrint::PDFDerivativeService,
      IiifPrint::TextExtractionDerivativeService
    ]
  )

  validates :title, presence: { message: 'Your work must have a title.' }

  self.indexer = GenericWorkIndexer

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include Hyrax::BasicMetadata
end
