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
        byebug
        attributes = {
            'identifier' => Array(identifiers).reject { |id| id["identifierType"] == "DOI" }.pluck("identifier"),
            'doi' => build_hyrax_work_doi,
            'title' => titles&.pluck("title"),
            # FIXME: This may not roundtrip since datacite normalizes the creator name
            'creator_name_type' => build_hyrax_work_creator('creator_name_type'),
            'creator_family_name' => build_hyrax_work_creator('creator_family_name'),
            'creator_given_name' => build_hyrax_work_creator('creator_given_name'),
            'creator_organization_name' => build_hyrax_work_creator('creator_organization_name'),
            'creator_ror' => build_hyrax_work_creator('creator_ror'),
            'creator_position' => build_hyrax_work_creator('creator_position'),
            #'creator' => [build_hyrax_work_creator.to_s],
            # 'creator_group' => build_hyrax_work_creator,
            'contributor' => contributors&.pluck("name"),
            'publisher' => Array(publisher),
            'date_created' => publication_year.present? ? [EDTF.parse(publication_year).strftime] : [],
            'description' => build_hyrax_work_description,
            'abstract' => build_hyrax_work_description&.join("\n"),
            'keyword' => subjects&.pluck("subject")
        }
        # hyrax_work_class = determine_hyrax_work_class
        # Only pass attributes that the work type knows about
        # hyrax_work_class.new(attributes.slice(*hyrax_work_class.attribute_names))
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

      def build_hyrax_work_doi
        Array(doi&.sub('https://doi.org/', ''))
      end

      def build_hyrax_work_description
        return nil if descriptions.blank?

        descriptions.pluck("description").map { |d| Array(d).join("\n") }
      end

      def build_hyrax_work_creator(creator_id)
        @build_hyrax_work_creator ||= creators.each_with_index.map do |creator, i|
          { "creator_organization_name" => creator["name"],
            "creator_family_name" => creator["familyName"],
            "creator_given_name" => creator["givenName"],
            "creator_name_type" => creator["nameType"].sub("Organizational", "Organisational"),
            "creator_ror" => creator["affiliation"].map{|a| a["affiliationIdentifier"].split("/").last}.first,
            "creator_position" => i.to_s
            #"creator_isni":creators&.pluck("name"),
            #"creator_grid":creators&.pluck("name"),
            #"creator_wikidata":creators&.pluck("name"),
            #"creator_orcid":creators&.pluck("name"),
            #"creator_institutional_relationship":[""],
          }
        end.sort_by { |c| c["creator_position"].to_i }
        @build_hyrax_work_creator.map{ |c| c[creator_id]}
      end
    end
  end
end
