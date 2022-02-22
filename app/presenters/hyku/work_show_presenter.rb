# frozen_string_literal: true

module Hyku
  class WorkShowPresenter < Hyrax::WorkShowPresenter
    Hyrax::MemberPresenterFactory.file_presenter_class = Hyrax::FileSetPresenter

    include MultipleMetadataFieldsHelper
    delegate :extent, :rendering_ids, :isni, :institution, :org_unit, :refereed, :doi, :original_doi, :isbn, :issn, :eissn,
             :funder, :fndr_project_ref, :add_info,
             :journal_title, :alternative_journal_title, :issue, :volume, :pagination, :article_num, :project_name, :rights_holder,
             :official_link, :place_of_publication, :series_name, :edition, :abstract, :version,
             :event_title, :event_date, :event_location, :book_title, :editor,
             :alternate_identifier, :related_identifier, :media, :duration, :related_exhibition, :related_exhibition_venue, :related_exhibition_date,
             :dewey, :library_of_congress_classification, :alt_title, :current_he_institution, :qualification_name, :qualification_level, :collection_names, :collection_id, :resource_type_label,
             to: :solr_document
    delegate :collection_presenters, to: :member_presenter_factory

    # assumes there can only be one doi
    def doi
      # doi_regex = %r{10\.\d{4,9}\/[-._;()\/:A-Z0-9]+}i
      # if solr_document.doi
      #   doi = Array.wrap(solr_document.doi).first # for doi could be single or array
      #   doi = doi.scan(doi_regex)&.join
      #   return "#{ENV.fetch('DOI_BASE_URL', 'https://handle.stage.datacite.org')}/#{doi}" if doi
      # end

      # if solr_document.original_doi
      #   original_doi = Array.wrap(solr_document.original_doi).first # for original_doi could be single or array
      #   original_doi = original_doi.scan(original_doi_regex)&.join
      #   return "#{ENV.fetch('DOI_BASE_URL', 'https://handle.stage.datacite.org')}/#{original_doi}" if original_doi
      # end

      solr_document.doi.present? ? solr_document.doi : solr_document.original_doi
    end

    # unlike doi, there can be multiple isbns
    def isbns
      isbn_regex = /((?:ISBN[- ]*13|ISBN[- ]*10|)\s*97[89][ -]*\d{1,5}[ -]*\d{1,7}[ -]*\d{1,6}[ -]*\d)|
                    ((?:[0-9][-]*){9}[ -]*[xX])|(^(?:[0-9][-]*){10}$)/x
      isbns = extract_from_identifier(isbn_regex)
      isbns&.flatten&.compact
    end

    def date_published
      date = solr_document['date_published_dtsim']
      return formatted_date(date) if date.present?
      solr_document['date_published_tesim'] # kept for backward compatibility
    end

    def date_accepted
      date = solr_document['date_accepted_dtsim']
      return formatted_date(date) if date.present?
      solr_document['date_accepted_tesim']
    end

    def date_submitted
      date = solr_document['date_submitted_dtsim']
      return formatted_date(date) if date.present?
      solr_document['date_submitted_tesim']
    end

    def file_licenses?
      unless @file_licenses_run
        @file_licenses = member_presenters.detect { |member| member&.license&.present? }
        @file_licenses_run = true
      end
      @file_licenses
    end

    def creator
      solr_document.formatted_creator
    end

    def creator_hash
      solr_document.creator
    end

    # Begin Featured Collections Methods
    def collection_featurable?
      user_can_feature_collection? && solr_document.public?
    end

    def display_feature_collection_link?
      collection_featurable? && FeaturedCollection.can_create_another? && !collection_featured?
    end

    def display_unfeature_collection_link?
      collection_featurable? && collection_featured?
    end

    def collection_featured?
      # only look this up if it's not boolean; ||= won't work here
      @collection_featured = FeaturedCollection.where(collection_id: solr_document.id).exists? if @collection_featured.nil?
      @collection_featured
    end

    def user_can_feature_collection?
      current_ability.can?(:create, FeaturedCollection)
    end
    # End Featured Collections Methods

    private

    def extract_from_identifier(rgx)
      if solr_document['identifier_tesim'].present?
        ref = solr_document['identifier_tesim'].map do |str|
          str.scan(rgx)
        end
      end
      ref
    end
  end
end
