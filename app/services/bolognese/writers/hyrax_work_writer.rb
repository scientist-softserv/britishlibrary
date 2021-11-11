# frozen_string_literal: true

# copied from hyrax-doi v0.2.0
require 'bolognese'

module Bolognese
  module Writers
    # Use this with Bolognese like the following:
    # m = Bolognese::Metadata.new(input: '10.18130/v3-k4an-w022')
    # Then crosswalk it with:
    # m.hyrax_work
    module HyraxWorkWriter
      def hyrax_work
        attributes = {
          'abstract' => build_hyrax_work_description&.join("\n"),
          'creator' => build_hyrax_work_creator,
          'contributor' => build_hyrax_work_contributor,
          'funder' => build_hyrax_work_funder,
          'date_accepted' => get_date_from_type('Accepted').first,
          'date_published' => publication_year.present? ? EDTF.parse(publication_year).strftime : nil,
          'date_submitted' => get_date_from_type('Submitted').first,
          'description' => build_hyrax_work_description,
          'doi' => build_hyrax_work_doi(doi),
          'identifier' => Array(identifiers).reject { |id| id["identifierType"] == "DOI" }.pluck("identifier"),
          'keyword' => subjects&.pluck("subject")&.uniq,
          'language' => Array(language),
          'license' => rights_list&.map { |r| r['rightsUri'].sub('legalcode', '') },
          'official_link' => url,
          'publisher' => Array(publisher),
          'related_identifier' => build_hyrax_work_related_identifier,
          'resource_type' => Array(resource_type),
          'title' => titles&.pluck("title")
        }
        _hyrax_work_class = determine_hyrax_work_class
        # Only pass attributes that the work type knows about
        # hyrax_work_class.new(attributes.slice(*hyrax_work_class.attribute_names))
        attributes
      end

      private

      def determine_hyrax_work_class
        # Need to check that the class `responds_to? :doi`?
        types["hyrax"]&.safe_constantize || build_hyrax_work_class
      end

      def build_hyrax_work_class
        Class.new(ActiveFedora::Base).tap do |c|
          c.include ::Hyrax::WorkBehavior
          c.include ::Hyrax::DOI::DOIBehavior
          # Put BasicMetadata include last since it finalizes the metadata schema
          c.include ::Hyrax::BasicMetadata
        end
      end

      def build_hyrax_work_doi(doi_uri)
        Array(doi_uri&.sub('https://doi.org/', ''))
      end

      def build_hyrax_work_description
        return nil if descriptions.blank?

        descriptions.pluck("description").map { |d| Array(d).join("\n") }
      end

      def get_date_from_type(date_type)
        dates.select { |d| d['dateType'] == date_type }.map { |d| d['date'] }
      end

      def resource_type
        return nil unless types['resourceTypeGeneral'].present?

        humanized = types['resourceTypeGeneral'].underscore.capitalize.tr('_', ' ')
        Hyrax::ResourceTypesService.select_options.select { |t| t.first == humanized }&.first&.last
      end

      def build_hyrax_work_child(field_name:, field:, index:)
        {
          "#{field_name}_organization_name" => field["name"],
          "#{field_name}_family_name" => field["familyName"],
          "#{field_name}_given_name" => field["givenName"],
          "#{field_name}_name_type" => field["nameType"]&.sub("Organizational", "Organisational"),
          "#{field_name}_ror" => field["affiliation"]&.map { |a| a["affiliationIdentifier"]&.split("/")&.last }&.first,
          "#{field_name}_position" => index.to_s
          #"creator_isni":creators&.pluck("name"),
          #"creator_grid":creators&.pluck("name"),
          #"creator_wikidata":creators&.pluck("name"),
          #"creator_orcid":creators&.pluck("name"),
          #"creator_institutional_relationship":[""],
        }
      end

      def build_hyrax_work_creator
        @build_hyrax_work_creator ||= Array(creators.each_with_index.map do |creator, i|
          build_hyrax_work_child(field_name: 'creator', field: creator, index: i)
          end.sort_by { |c| c["creator_position"].to_i }.to_json)
        @build_hyrax_work_creator = nil if @build_hyrax_work_creator == ["[]"]
        @build_hyrax_work_creator
      end

      def build_hyrax_work_contributor
        @build_hyrax_work_contributor ||= Array(contributors.each_with_index.map do |contributor, i|
          build_hyrax_work_child(field_name: 'contributor', field: contributor, index: i)
            .merge("contributor_type" => contributor["contributorType"])
          end.sort_by { |c| c["contributor_position"].to_i }.to_json)
        @build_hyrax_work_contributor = nil if @build_hyrax_work_contributor == ["[]"]
        @build_hyrax_work_contributor
      end

      def funder_identifier(funder)
        funder_id = {}
        funder_id = { "funder_doi" => funder["funderIdentifier"] } if funder['funderIdentifierType'] == 'Crossref Funder ID'
        funder_id = { "funder_ror" => funder["funderIdentifier"] } if funder['funderIdentifierType'] == 'ROR'
        funder_id = { "funder_isni" => funder["funderIdentifier"] } if funder['funderIdentifierType'] == 'ISNI'
        funder_id
      end

      def build_hyrax_work_funder
        @build_hyrax_work_funder ||= Array(funding_references.each_with_index.map do |funder, i|
          {
            "funder_name" => funder["funderName"],
            "funder_award" => Array(funder["awardNumber"]),
            "funder_position" => i.to_s
          }.merge(funder_identifier(funder))
          end.sort_by { |c| c["funder_position"].to_i }.to_json)
        @build_hyrax_work_funder = nil if @build_hyrax_work_funder == ["[]"]
        @build_hyrax_work_funder
      end

      def build_hyrax_work_related_identifier
        @build_hyrax_work_related_identifier ||= Array.wrap(related_identifiers.each_with_index.map do |identifier, i|
            {
              'related_identifier' => identifier['relatedIdentifier'],
              'related_identifier_type' => identifier['relatedIdentifierType'],
              'relation_type' => identifier['relationType']
            }
          end.to_json)
        @build_hyrax_work_related_identifier = nil if @build_hyrax_work_related_identifier == ["[]"]
        @build_hyrax_work_related_identifier
      end
    end
  end
end
