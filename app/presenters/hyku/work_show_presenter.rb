# frozen_string_literal: true

module Hyku
  class WorkShowPresenter < Hyrax::WorkShowPresenter
    Hyrax::MemberPresenterFactory.file_presenter_class = Hyrax::FileSetPresenter

    delegate :extent, :rendering_ids, :isni, :institution, :org_unit, :refereed, :doi, :isbn, :issn, :eissn,
             :funder, :fndr_project_ref, :add_info,
             :journal_title, :alternative_journal_title, :issue, :volume, :pagination, :article_num, :project_name, :rights_holder,
             :official_link, :place_of_publication, :series_name, :edition, :abstract, :version,
             :event_title, :event_date, :event_location, :book_title, :editor,
             :alternate_identifier, :related_identifier, :media, :duration, :related_exhibition, :related_exhibition_venue, :related_exhibition_date,
             :dewey, :library_of_congress_classification, :alt_title, :current_he_institution, :qualification_name, :qualification_level, :collection_names, :collection_id,
             to: :solr_document

    # assumes there can only be one doi
    def doi
      doi_regex = %r{10\.\d{4,9}\/[-._;()\/:A-Z0-9]+}i
      doi = extract_from_identifier(doi_regex)
      doi&.join
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
