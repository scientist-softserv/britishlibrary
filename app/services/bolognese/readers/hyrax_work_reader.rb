# frozen_string_literal: true

require 'bolognese'

module Bolognese
  module Readers
    # Use this with Bolognese like the following:
    # m = Bolognese::Metadata.new(input: work.attributes.merge(has_model: work.has_model.first).to_json, from: 'hyrax_work')
    # Then crosswalk it with:
    # m.datacite
    # Or:
    # m.ris
    # rubocop:disable Metrics/ModuleLength
    module HyraxWorkReader
      # Not usable right now given how Metadata#initialize works
      # def get_hyrax_work(id: nil, **options)
      #   work = ActiveFedora::Base.find(id)
      #   { "string" => work.attributes.merge(has_model: work.has_model).to_json }
      # end

      def read_hyrax_work(string: nil, **options)
        read_options = ActiveSupport::HashWithIndifferentAccess.new(options.except(:doi, :id, :url, :sandbox, :validate, :ra))
        meta = string.present? ? Maremma.from_json(string) : {}

        {
          "alternate_identifier" => read_alternate_identifiers(meta),
          "contributors" => read_hyrax_work_contributors(meta),
          "creators" => read_hyrax_work_creators(meta),
          "dates" => read_hyrax_work_dates(meta),
          "descriptions" => read_hyrax_work_descriptions(meta),
          "doi" => normalize_doi(meta.fetch('doi', nil)&.first),
          "funding_references" => read_hyrax_work_funding_references(meta),
          "identifiers" => read_hyrax_work_identifiers(meta),
          "related_items" => read_hyrax_work_journal(meta),
          "language" => read_hyrax_work_language(meta),
          "official_link" => normalize_id(meta.fetch("URL", nil)),
          "publication_year" => read_hyrax_work_publication_year(meta),
          "publisher" => read_hyrax_work_publisher(meta),
          "related_identifiers" => read_hyrax_work_related_identifiers(meta),
          "rights_list" => read_hyrax_work_rights_list(meta),
          "sizes" => read_hyrax_work_size(meta),
          "subjects" => read_hyrax_work_subjects(meta),
          "titles" => read_hyrax_work_titles(meta),
          "types" => read_hyrax_work_types(meta),
          "version" => read_hyrax_work_version(meta),
          "volume_number" => meta.fetch('volume', nil)&.first
          # "container" => container,
          # "id" => meta.fetch('id', nil),
          # "state" => state
          # "version_info" => meta.fetch("version", nil),
        }.merge(read_options)
      end

      private

        def read_hyrax_work_version(meta)
          (meta.fetch('version_number', []) + meta.fetch('version', []))&.first
        end

        def read_alternate_identifiers(meta)
          JSON.parse(meta.fetch('alternate_identifier').first || "[]").each do |ai|
            {
              "alternateIdentifier" => ai['alternate_identifier'],
              "alternateIdentifierType" => ai['alternate_identifier_type']
            }
          end
        end

        # map work type to an allowed resourceTypeGeneral value
        def work_to_resource_type_general_map
          {
            'GenericWork': 'Text',
            'Image': 'Image',
            'Book': 'Book',
            'BookContribution': 'BookChapter',
            'Article': 'Text',
            'ConferenceItem': 'ConferencePaper',
            'Dataset': 'Dataset',
            'ExhibitionItem': 'Text',
            'Report': 'Report',
            'ThesisOrDissertation': 'Dissertation',
            'TimeBasedMedia': 'Audiovisual'
          }
        end

        # map resource_type to an allowed resrouceTypeGeneral value
        # This is for when the default hyrax type => RTG doesn't quite work
        def resource_type_to_resource_type_general_map
          {
            'Journal article': 'JournalArticle', #Article
            'Data paper': 'DataPaper',
            'Book editorial': 'Text', #Book
            'Abstract': 'Text', #ConferenceItem
            'Lecture': 'Event',
            'Poster (published)': 'Image',
            'Poster (unpublished)': 'Image',
            'Presentation': 'Event',
            'Software': 'Software', #Dataset
            'Exhibition': 'Event', #ExhibitionItem
            'Exhibition-related event': 'Event',
            'Exhibition audio-visual guide': 'Audiovisual',
            'Festival': 'Event',
            'Cartographic material': 'Image', #GenericWork
            'Interactive resource': 'InteractiveResource',
            'Journal issue': 'Journal',
            'Leaflet': 'Leaflet',
            'Learning object': 'InteractiveResource',
            'Musical notation': 'Other',
            'Website': 'InteractiveResource',
            'Workflow': 'Workflow',
            'Other': 'Other'
          }
        end

        def read_hyrax_work_types(meta)
          # First we get the hyrax type from the model
          hyrax_resource_type = meta.fetch('has_model', nil) || "Work"
          # Our datacite resource type will be whatever has been selected as the resource type on the form
          resource_type = Hyrax::ResourceTypesService.label(meta.fetch('resource_type', nil).first)
          # If we do not have a resource point by this point, we will default to the work type
          resource_type = hyrax_resource_type if resource_type.blank? || resource_type.match(/\[Error/)

          # Now for resourceTypeGeneral use map from work type to datacite RTG
          resource_type_general = work_to_resource_type_general_map[hyrax_resource_type.to_sym]
          # But there is some further nuance we can apply in some cases
          resource_type_general = resource_type_to_resource_type_general_map[resource_type.to_sym] if resource_type_to_resource_type_general_map[resource_type.to_sym].present?
          {
            "resourceTypeGeneral" => resource_type_general,
            "resourceType" => resource_type,
            "hyrax" => hyrax_resource_type
          }.compact
        end

        def read_hyrax_work_journal(meta)
          relation = {}

          journal_title = meta.fetch('journal_title', nil)
          # date_published = meta.fetch('date_published', nil) # rubocop: unusued var
          eissn = meta.fetch('eissn', nil)
          volume = meta.fetch('volume', nil)&.first

          if journal_title
            relation['relatedItemType'] = 'Journal'
            relation['relationType'] = 'IsPublishedIn'
            relation["relatedItemIdentifier"] = {
              "relatedItemIdentifier" => eissn,
              "relatedItemIdentifierType" => 'EISSN'
            }
            relation['titles'] = [{ 'title' => journal_title }]
            relation['publicationYear'] = read_hyrax_work_publication_year(meta)
            relation['volume'] = volume if volume
          end

          Array.wrap(relation) if relation.present?
        end

        def read_hyrax_work_related_identifiers(meta)
          output = []
          JSON.parse(meta.fetch('related_identifier').first || "[]").each do |ri|
            output << {
              "relatedIdentifier" => ri['related_identifier'],
              "relatedIdentifierType" => ri['related_identifier_type'],
              "relationType" => ri['relation_type']
            }
          end

          meta.fetch('related_url', []).each do |url|
            output << {
              "relatedIdentifier" => url,
              "relatedIdentifierType" => 'URL',
              "relationType" => 'References'
            }
          end

          eissn = meta.fetch('eissn', nil)
          if eissn
            output << {
              "related_identifier" => eissn,
              "relatedIdentifierType" => "EISSN",
              "relationType" => "IsReferencedBy"
            }
          end

          output
        end

        def read_hyrax_work_funding_references(meta)
          output = []
          JSON.parse(meta.fetch('funder').first || "[]").sort_by { |c| c["funder_position"].to_i }.each do |ri|
            # [{"funder_name"=>"testo", "funder_doi"=>"testp", "funder_position"=>"0", "funder_isni"=>"testq", "funder_ror"=>"testr", "funder_award"=>["tests"]}]
            funder_id, funder_id_type = if ri['funder_doi'].present?
                                          [ri['funder_doi'], 'Crossref Funder ID']
                                        elsif ri['funder_isni'].present?
                                          [ri['funder_isni'], 'ISNI']
                                        elsif ri['funder_ror'].present?
                                          [ri['funder_ror'], 'ROR']
                                        end
            fields = {
              "funderName" => ri['funder_name'],
              "funderIdentifier" => funder_id,
              "funderIdentifierType" => funder_id_type
            }

            award = ri['funder_award']&.first || meta.fetch('fndr_project_ref', nil)
            if award
              fields["awardNumber"] = award
              fields["awardURI"] = ""
              fields["awardTitle"] = ""
            end
            output << fields
          end

          output
        end

        def read_hyrax_work_rights_list(meta)
          output = []
          meta.fetch('license', []).each do |r|
            output << { 'rightsUri' => "#{r}legalcode" }
          end

          meta.fetch('rights_statement', []).each do |r|
            output << { 'rightsUri' => r }
          end

          output
        end

        def read_hyrax_work_dates(meta)
          all_dates = []
          date = meta.fetch("date_accepted", nil).presence
          all_dates << { "date" => date.to_s, "dateType" => "Accepted" } if date
          date ||= meta.fetch("date_submitted", nil).presence
          all_dates << { "date" => date.to_s, "dateType" => "Submitted" } if date
        end

        def read_hyrax_work_creators(meta)
          return if meta.fetch("creator", nil).blank?

          authors = create_authors(meta, 'creator')
          get_authors(authors) if authors.present?
        end

        def read_hyrax_work_contributors(meta)
          authors = meta.fetch("contributor", nil).present? ? create_authors(meta, 'contributor') : []
          meta.fetch('rights_holder', []).each do |rights_holder|
            authors << {
              'contributorName' => rights_holder,
              'contributorType' => 'RightsHolder'
            }
          end

          get_authors(authors) if authors.present?
        end

        def reader_name_by_type(author, author_type, name_type)
          organization = name_type.to_s.match(/org/i) || author["#{author_type}_family_name"].blank?
          if organization
            [author["#{author_type}_organization_name"], nil, nil]
          else
            [
              nil,
              author["#{author_type}_given_name"],
              author["#{author_type}_family_name"]
            ]
          end
        end

        def create_authors(meta, author_type)
          authors = []
          JSON.parse(meta[author_type].first).sort_by { |c| c["#{author_type}_position"].to_i }.each do |author|
            name_type = author["#{author_type}_name_type"]
            name_type = "Organizational" if name_type == "Organisational"
            name, given_name, family_name = reader_name_by_type(author, author_type, name_type)
            name_identifier = []
            ['orcid', 'ror', 'isni', 'grid', 'wikidata'].each do |id_type|
              next if author["#{author_type}_#{id_type}"].blank?
              name_identifier << {
                "nameIdentifierScheme" => id_type.upcase,
                "__content__" => author["#{author_type}_#{id_type}"]
              }
            end
            name_identifier = nil if name_identifier.blank?

            author_hash = {  "nameType" => name_type,
                             "creatorName" => name,
                             "givenName" => given_name,
                             "familyName" => family_name,
                             "nameIdentifier" => name_identifier }.compact

            authors << author_hash
          end
          authors
        end

        def read_hyrax_work_titles(meta)
          Array.wrap(meta.fetch("title", [])).select(&:present?).collect { |r| { "title" => sanitize(r) } }
        end

        # rubocop:disable Metrics/MethodLength
        def read_hyrax_work_descriptions(meta)
          descriptions = []
          if meta.fetch('description').present?
            meta.fetch('description').each do |desc|
              descriptions << {
                "description" => sanitize(desc),
                "descriptionType" => 'Other'
              }
            end
          end

          if meta.fetch('abstract').present?
            descriptions << {
              "description" => sanitize(meta.fetch('abstract')),
              "descriptionType" => 'Abstract'
            }
          end

          if meta.fetch('add_info').present?
            descriptions << {
              "description" => sanitize(meta.fetch('add_info')),
              "descriptionType" => 'Other'
            }
          end

          if meta.fetch('event_title').present?
            descriptions << {
              "description" => sanitize(meta.fetch('event_title')),
              "descriptionType" => 'Other'
            }
          end

          if meta.fetch('place_of_publication').present?
            descriptions << {
              "description" => sanitize(meta.fetch('place_of_publication')),
              "descriptionType" => 'Other'
            }
          end

          if meta.fetch('series_name').present?
            descriptions << {
              "description" => sanitize(meta.fetch('series_name')),
              "descriptionType" => 'SeriesInformation'
            }
          end

          descriptions.presence
        end
        # rubocop:enable Metrics/MethodLength

        def read_hyrax_work_publication_year(meta)
          # First we get the year from the date_published (BL array date)
          date = date_year(meta.fetch("date_published", nil))
          # No date_published, use date_Accepted (BL array date)
          date ||= date_year(meta.fetch("date_accepted", nil))
          # Neither of those fall back to date_uploaded (always set, Hyrax string date)
          date_uploaded = meta.fetch("date_uploaded", nil)
          date ||= Date.strptime(date_uploaded.to_s, "%Y-%m-%d").year.to_s
          date
        end

        def date_year(date)
          date&.split('-')&.first
        end

        def read_hyrax_work_subjects(meta)
          keywords = Array.wrap(meta.fetch("keyword", nil)).select(&:present?).collect { |r| { "subject" => sanitize(r) } }
          library_of_congress_classifications = Array.wrap(meta.fetch("library_of_congress_classification", nil)).select(&:present?).collect { |r| { "subject" => sanitize(r) } }
          subjects = Array.wrap(meta.fetch("subject", nil)).select(&:present?).collect { |r| { "subject" => sanitize(r) } }
          # deweys = Array.wrap(meta.fetch("dewey", nil)).select(&:present?).collect { |r| { "subject" => sanitize(r) } } # unused var
          keywords + library_of_congress_classifications + subjects
        end

        def read_hyrax_work_identifiers(meta)
          Array.wrap(meta.fetch("identifier", nil)).select(&:present?).collect { |r| { "identifier" => sanitize(r) } }
        end

        def read_hyrax_work_size(meta)
          pagination = meta.fetch('pagination', nil)
          [pagination] if pagination
        end

        def read_hyrax_work_language(meta)
          meta.fetch('language', []).first
        end

        def read_hyrax_work_publisher(meta)
          # Fallback to ':unav' since this is a required field for datacite
          # TODO: Should this default to application_name?
          parse_attributes(meta.fetch("publisher")).to_s.strip.presence || ":unav"
        end
    end
    # rubocop:enable Metrics/ModuleLength
  end
end
