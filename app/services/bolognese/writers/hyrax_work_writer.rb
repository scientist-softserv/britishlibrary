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
        # byebug
        attributes = {
            'identifier' => Array(identifiers).reject { |id| id["identifierType"] == "DOI" }.pluck("identifier"),
            'doi' => build_hyrax_work_doi(doi),
            'title' => titles&.pluck("title"),
            # FIXME: This may not roundtrip since datacite normalizes the creator name
            'creator_name_type' => build_hyrax_work_creator('creator_name_type'),
            'creator_family_name' => build_hyrax_work_creator('creator_family_name'),
            'creator_given_name' => build_hyrax_work_creator('creator_given_name'),
            'creator_organization_name' => build_hyrax_work_creator('creator_organization_name'),
            'creator_ror' => build_hyrax_work_creator('creator_ror'),
            'creator_position' => build_hyrax_work_creator('creator_position'),
            'contributor_name_type' => build_hyrax_work_contributor('contributor_name_type'),
            'contributor_family_name' => build_hyrax_work_contributor('contributor_family_name'),
            'contributor_given_name' => build_hyrax_work_contributor('contributor_given_name'),
            'contributor_organization_name' => build_hyrax_work_contributor('contributor_organization_name'),
            'contributor_ror' => build_hyrax_work_contributor('contributor_ror'),
            'contributor_type' => build_hyrax_work_contributor('contributor_type'),
            'contributor_position' => build_hyrax_work_contributor('contributor_position'),
            'funder_position' => build_hyrax_work_funder('funder_position'),
            'funder_name' => build_hyrax_work_funder('funder_name'),
            'funder_doi' => build_hyrax_work_funder('funder_doi'),
            'funder_ror' => build_hyrax_work_funder('funder_ror'),
            'funder_isni' => build_hyrax_work_funder('funder_isni'),
            'funder_award' => build_hyrax_work_funder('funder_award'),
            'related_identifier' => related_identifiers&.pluck('relatedIdentifier'),
            'related_identifier_type' => related_identifiers&.pluck('relatedIdentifierType'),
            'relation_type' => related_identifiers&.pluck('relationType'),
            'publisher' => Array(publisher),
            'date_published' => publication_year.present? ? [EDTF.parse(publication_year).strftime] : [],
            'date_accepted' => get_date_from_type('Accepted'),
            'date_submitted' => get_date_from_type('Submitted'),
            'description' => build_hyrax_work_description,
            'abstract' => build_hyrax_work_description&.join("\n"),
            'language' => language,
            'resource_type' => resource_type,
            'license' => rights_list.map { |r| r['rightsUri'].sub('legalcode', '') },
            'keyword' => subjects&.pluck("subject")
        }
        # byebug
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

        humanized = types['resourceTypeGeneral'].underscore.capitalize.gsub('_',' ')
        Hyrax::ResourceTypesService.select_options.select { |t| t.first == humanized }&.first&.last
      end

      def build_hyrax_work_child(field_name: ,field:, index: )
        { "#{field_name}_organization_name" => field["name"],
          "#{field_name}_family_name" => field["familyName"],
          "#{field_name}_given_name" => field["givenName"],
          "#{field_name}_name_type" => field["nameType"].sub("Organizational", "Organisational"),
          "#{field_name}_ror" => field["affiliation"].map{|a| a["affiliationIdentifier"].split("/").last}.first,
          "#{field_name}_position" => index.to_s
          #"creator_isni":creators&.pluck("name"),
          #"creator_grid":creators&.pluck("name"),
          #"creator_wikidata":creators&.pluck("name"),
          #"creator_orcid":creators&.pluck("name"),
          #"creator_institutional_relationship":[""],
        }
      end

      def build_hyrax_work_creator(creator_id)
        @build_hyrax_work_creator ||= creators.each_with_index.map do |creator, i|
          build_hyrax_work_child(field_name: 'creator', field: creator, index: i )
        end.sort_by { |c| c["creator_position"].to_i }
        @build_hyrax_work_creator.map{ |c| c[creator_id]}
      end

      def build_hyrax_work_contributor(contributor_id)
        @build_hyrax_work_contributor ||= contributors.each_with_index.map do |contributor, i|
          build_hyrax_work_child(field_name: 'contributor', field: contributor, index: i )
              .merge({
                         "contributor_type" => contributor["contributorType"]
                     })
        end.sort_by { |c| c["contributor_position"].to_i }
        @build_hyrax_work_contributor.map{ |c| c[contributor_id]}
      end

      def funder_identifier(funder)
        funder_id = {}
        funder_id = { "funder_doi" => funder["funderIdentifier"] } if(funder['funderIdentifierType'] == 'Crossref Funder ID')
        funder_id = { "funder_ror" => funder["funderIdentifier"] } if(funder['funderIdentifierType'] == 'ROR')
        funder_id = { "funder_isni" => funder["funderIdentifier"] } if(funder['funderIdentifierType'] == 'ISNI')
        funder_id
      end

      def build_hyrax_work_funder(funder_id)
        @build_hyrax_work_funder ||= funding_references.each_with_index.map do |funder, i|
          {
              "funder_name" => funder["funderName"],
              "funder_award" => funder["awardNumber"],
              "funder_position" => i.to_s
          }.merge(funder_identifier(funder))
        end.sort_by { |c| c["funder_position"].to_i }
        @build_hyrax_work_funder.map{ |c| c[funder_id]}
      end
    end
  end
end
