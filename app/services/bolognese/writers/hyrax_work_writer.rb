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
          'date_published' => publication_date,
          'date_submitted' => get_date_from_type('Submitted').first,
          # Not used 'description' => build_hyrax_work_description,
          'doi' => build_hyrax_work_doi(doi),
          'original_doi' => build_hyrax_work_doi(doi)&.first,
          'issn' => issn,
          'eissn' => eissn,
          # not used 'identifier' => Array(identifiers).reject { |id| ['doi', 'issn', 'eissn'].include?(id["identifierType"].downcase.strip) }.pluck("identifier"),
          'alternate_identifier' => alternate_identifier,
          'keyword' => subjects&.pluck("subject")&.uniq,
          'language' => Array(language),
          'license' => rights_list&.map { |r| r['rightsUri'].sub('legalcode', '') },
          'journal_title' => journal_title,
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

      def raw_xml
        @raw_xml ||= Maremma.from_xml(string).dig("crossref_result", "query_result", "body", "query", "doi_record") || {}
      rescue
        {}
      end

      def raw_meta
        @raw_meta = raw_xml.dig("doi_record", "crossref", "error").nil? ? raw_xml : {}
      end

      def raw_query
        # query contains information from outside metadata schema, e.g. publisher name
        @raw_query ||= Maremma.from_xml(string).dig("crossref_result", "query_result", "body", "query") || {}
      rescue
        {}
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

      def issn
        val = Array.wrap(raw_meta&.dig("crossref", "journal", "journal_metadata", "issn"))&.select {|i| i['media_type'] == 'print'}&.pluck('__content__')&.first
        normalize_issn(val) if val.present?
      end

      def eissn
        val = Array.wrap(raw_meta&.dig("crossref", "journal", "journal_metadata", "issn"))&.select {|i| i['media_type'] == 'electronic'}&.pluck('__content__')&.first
        normalize_issn(val) if val.present?
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
          "#{field_name}_position" => index.to_s,
          "#{field_name}_orcid" => field["nameIdentifiers"]&.select { |a| a["nameIdentifierScheme"]&.match(/orcid/i) }&.map { |a| a['nameIdentifier'] },
          "#{field_name}_isni" => field["nameIdentifiers"]&.select { |a| a["nameIdentifierScheme"]&.match(/isni/i) }&.map { |a| a['nameIdentifier'] },
          "#{field_name}_grid" => field["nameIdentifiers"]&.select { |a| a["nameIdentifierScheme"]&.match(/grid/i) }&.map { |a| a['nameIdentifier'] }
          #"creator_wikidata":creators&.pluck("name"),
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
        return @build_hyrax_work_related_identifier if @build_hyrax_work_related_identifier.present?
        selected_identifiers = related_identifiers.reject { |i| ['references', 'issn', 'eissn'].include?(i['relatedIdentifierType'].downcase.strip) || i['relationType'].downcase == "references" }
        selected_identifiers.map! do |i|
          {
            'related_identifier' => i['relatedIdentifier'],
            'related_identifier_type' => i['relatedIdentifierType'],
            'relation_type' => i['relationType']
          }
        end
        @build_hyrax_work_related_identifier = Array.wrap(selected_identifiers.to_json)
        @build_hyrax_work_related_identifier = nil if @build_hyrax_work_related_identifier == ["[]"]
        @build_hyrax_work_related_identifier
      end

      def alternate_identifier
        return @alterante_identifier if @alterante_identifier.present?
        selected_identifiers =  Array(identifiers).reject { |id| ['doi', 'issn', 'eissn'].include?(id["identifierType"].downcase.strip) }
        selected_identifiers.map! do |i|
          {
            'alternate_identifier' => i['identifier'],
            'alternate_identifier_type' => i['identifierType'],
          }
        end
        @alterante_identifier = Array.wrap(selected_identifiers.to_json)
        @alterante_identifier = nil if @alterante_identifier == ["[]"]
        @alterante_identifier
      end

      def journal_title
        container&.[]('type') == 'Journal' ? container['title'] : nil
      end

      def publication_date
        date_hash = Array.wrap(raw_meta&.dig('crossref', 'journal', 'journal_issue', 'publication_date')).first
        date_hash = Array.wrap(raw_meta&.dig('crossref', 'journal', 'journal_article', 'publication_date')).first
        if date_hash.present?
          date = [date_hash['year'], date_hash['month'], date_hash['day']].reject {|a| a.blank?}
          date = date.join('-')
        end
        
        date || publication_year
      end
    end
  end
end
