# frozen_string_literal: true

class Image < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Ubiquity::UniversalMetadata
  include Ubiquity::SharedMetadata
  include Ubiquity::AllModelsVirtualFields
  include Ubiquity::WorksVirtualFields
  # include Ubiquity::UpdateSharedIndex
  include Ubiquity::FileAvailabilityFaceting
  # include ::Ubiquity::CachingSingle
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

  property :extent, predicate: ::RDF::Vocab::DC.extent, multiple: true do |index|
    index.as :stored_searchable
  end

  # This must come after the properties because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  self.indexer = ImageIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
end
