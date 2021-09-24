module Ubiquity
  module UniversalMetadata
    extend ActiveSupport::Concern
    #include Ubiquity::CsvExportUtil
    #include Ubiquity::WorkAndCollectionMetadata
    #include Ubiquity::WorkDoiLifecycle
    #include Ubiquity::TrackDoiOptions

    # include here properties (fields) shared across all templates
    # also see SharedMetadata
    included do
      property :bulkrax_identifier, predicate: ::RDF::URI("https://iro.bl.uk/resource#bulkraxIdentifier"), multiple: false do |index|
        index.as :stored_searchable, :facetable
      end
      property :institution, predicate: ::RDF::Vocab::ORG.organization do |index|
        index.as :stored_searchable, :facetable
      end
      property :org_unit, predicate: ::RDF::Vocab::ORG.OrganizationalUnit do |index|
        index.as :stored_searchable
      end
      property :refereed, predicate: ::RDF::Vocab::BIBO.term("status/peerReviewed"), multiple: false do |index|
        index.as :stored_searchable
      end
      property :funder, predicate: ::RDF::Vocab::MARCRelators.fnd do |index|
        index.as :stored_searchable
      end
      property :fndr_project_ref, predicate: ::RDF::Vocab::BF2.awards do |index|
        index.as :stored_searchable
      end
      property :add_info, predicate: ::RDF::Vocab::BIBO.term(:Note), multiple: false do |index|
        index.as :stored_searchable
      end
      property :date_published, predicate: ::RDF::Vocab::DC.available, multiple: false do |index|
        index.as :stored_searchable
      end
      property :date_accepted, predicate: ::RDF::Vocab::DC.dateAccepted, multiple: false do |index|
        index.as :stored_searchable
      end
      property :date_submitted, predicate: ::RDF::Vocab::Bibframe.originDate, multiple: false do |index|
        index.as :stored_searchable
      end
      property :project_name, predicate: ::RDF::Vocab::BF2.term(:CollectiveTitle) do |index|
        index.as :stored_searchable
      end
      property :rights_holder, predicate: ::RDF::Vocab::DC.rightsHolder do |index|
        index.as :stored_searchable
      end
      property :doi, predicate: ::RDF::Vocab::BIBO.doi, multiple: false do |index|
        index.as :stored_searchable
      end

      property :place_of_publication, predicate: ::RDF::Vocab::BF2.term(:Place) do |index|
        index.as :stored_searchable, :facetable
      end
      property :abstract, predicate: ::RDF::Vocab::DC.abstract, multiple: false do |index|
        index.type :text
        index.as :stored_searchable
      end
      property :alternate_identifier, predicate: ::RDF::Vocab::BF2.term(:Local) do |index|
        index.as :stored_searchable
      end
      property :related_identifier, predicate: ::RDF::Vocab::BF2.identifiedBy do |index|
        index.as :stored_searchable
      end
      property :creator_search, predicate: ::RDF::Vocab::SCHEMA.creator do |index|
        index.as :stored_searchable, :facetable
      end
      property :library_of_congress_classification, predicate: ::RDF::Vocab::BF2.term(:ClassificationLcc) do |index|
        index.as :stored_searchable, :facetable
      end
      property :doi_options, predicate: ::RDF::Vocab::Bibframe.doi, multiple: false do |index|
        index.as :stored_searchable
      end
      property :draft_doi, predicate: ::RDF::Vocab::BF2.Doi, multiple: false do |index|
        index.as :stored_searchable
      end
      property :disable_draft_doi, predicate: ::RDF::Vocab::Bibframe.label, multiple: false do |index|
        index.as :stored_searchable
      end
      property :alt_title, predicate: ::RDF::Vocab::DC.alternative, multiple: true do |index|
        index.as :stored_searchable
      end
      property :dewey, predicate: ::RDF::Vocab::SCHEMA.CategoryCode, multiple: false do |index|
        index.as :stored_searchable
      end
      property :file_availability, predicate: ::RDF::Vocab::SCHEMA.ItemAvailability do |index|
        index.as :stored_searchable, :facetable
      end
      property :collection_id, predicate: ::RDF::Vocab::BF2.identifies do |index|
        index.as :stored_searchable, :facetable
      end
      property :collection_names, predicate: ::RDF::Vocab::DC11.term(:collect) do |index|
        index.as :stored_searchable, :facetable
      end

    end

    def standardize_dates
      self.date_published = parse_dates(self.date_published)
      self.date_submitted = parse_dates(self.date_submitted)
      self.date_accepted = parse_dates(self.date_accepted)
      save
    end

    def parse_dates(date)
      return nil if date.nil?

      if date.match(/[0-9]{4}-[0-9]{2}-[0-9]{2}/)
        return date
      elsif date.match(/[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}/)
        parsed_date = Date.strptime(date, "%Y-%m-%d") rescue date
      elsif date.match(/[0-9]{4}-[0-9]{1,2}/)
        parsed_date = Date.strptime(date, "%Y-%m") rescue date
      elsif date.match(/[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4}/)
        begin
          parsed_date = Date.strptime(date, "%m/%d/%Y")
        rescue Date::Error
          parsed_date = Date.strptime(date, "%d/%m/%Y") rescue date
        end
      elsif date.match(/[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{2}/)
        begin
          parsed_date = Date.strptime(date, "%m/%d/%y")
        rescue Date::Error
          parsed_date = Date.strptime(date, "%d/%m/%y") rescue date
        end
      elsif date.match(/[0-9]{4}/)
        parsed_date = Date.strptime(date, "%Y")
      else
        return date
      end
      parsed_date.to_s
    end

  end
end
