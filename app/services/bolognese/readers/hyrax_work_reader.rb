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
          # "id" => meta.fetch('id', nil),
          "identifiers" => read_hyrax_work_identifiers(meta),
          "types" => read_hyrax_work_types(meta),
          "doi" => normalize_doi(meta.fetch('doi', nil)&.first),
          # "url" => normalize_id(meta.fetch("URL", nil)),
          "titles" => read_hyrax_work_titles(meta),
          "creators" => read_hyrax_work_creators(meta),
          "contributors" => read_hyrax_work_contributors(meta),
          # "container" => container,
          "publisher" => read_hyrax_work_publisher(meta),
          "related_identifiers" => read_hyrax_work_related_identifiers(meta),
          "dates" => read_hyrax_work_dates(meta),
          "publication_year" => read_hyrax_work_publication_year(meta),
          "descriptions" => read_hyrax_work_descriptions(meta),
          "rights_list" => read_hyrax_work_rights_list(meta),
          # "version_info" => meta.fetch("version", nil),
          "subjects" => read_hyrax_work_subjects(meta)
          # "state" => state
        }.merge(read_options)
      end

      private

      def read_hyrax_work_types(meta)
        # TODO: Map work.resource_type or work.
        resource_type_general = "Other"
        hyrax_resource_type = meta.fetch('has_model', nil) || "Work"
        resource_type = meta.fetch('resource_type', nil).presence || hyrax_resource_type
        {
          "resourceTypeGeneral" => resource_type_general,
          "resourceType" => resource_type,
          "hyrax" => hyrax_resource_type
        }.compact
      end

      def read_hyrax_work_related_identifiers(meta)
        output = []
        eval(meta.fetch('related_identifier', nil).first).each do |ri|
          output << {
              "relatedIdentifier" => ri[:related_identifier],
              "relatedIdentifierType" => ri[:related_identifier_type],
              "relationType" => ri[:relation_type]
          }
        end
        output
      end

      def read_hyrax_work_rights_list(meta)
        output = []
        meta.fetch('license', nil).each do |r|

        end
        output
      end

      def read_hyrax_work_dates(meta)
        all_dates = []
        date = meta.fetch("date_accepted", nil).presence
        all_dates << {"date" => date.to_s, "dateType" => "Accepted" } if date
        date ||= meta.fetch("date_submitted", nil).presence
        all_dates << {"date" => date.to_s, "dateType" => "Submitted" } if date
      end

      def read_hyrax_work_creators(meta)
        return unless meta.fetch("creator", nil).present?

        authors = create_authors(meta, 'creator')
        get_authors(authors) if authors.present?
      end

      def read_hyrax_work_contributors(meta)
        return unless meta.fetch("contributor", nil).present?

        authors = create_authors(meta, 'contributor')
        get_authors(authors) if authors.present?
      end

      def create_authors(meta, author_type)
        authors = []
        eval(meta[author_type].first).sort_by { |c| c["#{author_type}_position"].to_i }.each do |author|
          name_type = author[:"#{author_type}_name_type"]
          given_name = author[:"#{author_type}_given_name"]
          family_name = author[:"#{author_type}_family_name"]
          name = author[:"#{author_type}_organization_name"]
          affiliation = {"affiliationIdentifier"=>"https://ror.org/#{author[:"#{author_type}_ror"]}",
                         "affiliationIdentifierScheme"=>"ROR"} if author[:"#{author_type}_ror"].presence
          nameIdentifier = []
          if author[:"#{author_type}_orcid"].present?
            nameIdentifier["nameIdentifierScheme"] = "ORCID"
            nameIdentifier["__content__"] = author[:"#{author_type}_orcid"]
          end

          author_hash = {  "nameType" => name_type,
                           "creatorName" => name,
                           "givenName" => given_name,
                           "familyName" => family_name,
                           "nameIdentifier" => nameIdentifier,
                           "affiliation" => affiliation }.compact

          authors << author_hash

        end
        authors
      end

      def read_hyrax_work_titles(meta)
        Array.wrap(meta.fetch("title", nil)).select(&:present?).collect { |r| { "title" => sanitize(r) } }
      end

      def read_hyrax_work_descriptions(meta)
        Array.wrap(meta.fetch("description", nil)).select(&:present?).collect { |r| { "description" => sanitize(r) } }
      end

      def read_hyrax_work_publication_year(meta)
        date = meta.fetch("date_published", nil)
        date ||= meta.fetch("date_created", nil)&.first
        date ||= meta.fetch("date_uploaded", nil)
        Date.strptime(date.to_s, "%Y-%m-%d").year
      rescue StandardError
        Time.zone.today.year
      end

      def read_hyrax_work_subjects(meta)
        Array.wrap(meta.fetch("keyword", nil)).select(&:present?).collect { |r| { "subject" => sanitize(r) } }
      end

      def read_hyrax_work_identifiers(meta)
        Array.wrap(meta.fetch("identifier", nil)).select(&:present?).collect { |r| { "identifier" => sanitize(r) } }
      end

      def read_hyrax_work_publisher(meta)
        # Fallback to ':unav' since this is a required field for datacite
        # TODO: Should this default to application_name?
        parse_attributes(meta.fetch("publisher")).to_s.strip.presence || ":unav"
      end
    end
  end
end
