# frozen_string_literal: true

require 'nokogiri'
module Bulkrax
  # Custom XML Entry for British Library's Electronic Theses and Dissertations.
  class XmlEtdDcEntry < XmlEntry
    serialize :raw_metadata, JSON

    def factory_class
      ThesisOrDissertation
    end

    def build_metadata
      raise StandardError, 'Record not found' if record.nil?
      raise StandardError, "Missing source identifier (#{source_identifier})" if raw_metadata[source_identifier].blank?
      self.parsed_metadata = {}
      parsed_metadata[work_identifier] = [raw_metadata[source_identifier]]
      field_mapping_from_values_for_xml_element_names.each do |element_name|
        # TODO: Refactor this so we don't have duplicate loops and multiple places that repeat
        #       knowledge (e.g. what's the field name, or how we loop over elements)
        next if complicated_elements.include?(element_name)
        elements = record.xpath("//*[name()='#{element_name}']")
        next if elements.blank?
        elements.each do |el|
          el.children.each do |child|
            content = child.content
            add_metadata(element_name, content) if content.present?
          end
        end
      end
      add_model
      add_complicated_fields
      add_visibility
      add_rights_statement
      add_admin_set_id
      add_collections

      parsed_metadata['file'] = raw_metadata['file']

      add_local
      raise StandardError, "title is required" if parsed_metadata['title'].blank?
      parsed_metadata
    end

    def add_model
      parsed_metadata['model'] = 'ThesisOrDissertation'
    end

    def complicated_elements
      %w[authoridentifier_isni authoridentifier_orcid subject identifier language provenance source relation advisor creator] # maybe embargo_date
    end

    def add_complicated_fields
      add_authoridentifier
      add_subject
      add_identifier
      add_language
      add_creator
      add_contributor

      # alt identifier
    end

    # @todo consider how we might put this "configuration logic" in the parser where it's a bit more visible
    def add_authoridentifier
      add_complicated_element('authoridentifier_isni', 'authoridentifier', 'uketdterms:ISNI')
      add_complicated_element('authoridentifier_orcid', 'authoridentifier', 'uketdterms:ORCID')
    end

    # @todo consider how we might put this "configuration logic" in the parser where it's a bit more visible
    def add_subject
      add_complicated_element('subject', 'subject', 'dcterms:Ddc')
    end

    # @todo consider how we might put this "configuration logic" in the parser where it's a bit more visible
    def add_identifier
      add_complicated_element('identifier', 'identifier', 'dcterms:DOI')
    end

    def add_language
      add_complicated_element('language', 'language', 'dcterms:ISO639-2')
    end

    def add_complicated_element(element_label, element_name, type_value)
      elements = record.xpath("//*[name()='#{element_name}']")
      return if elements.blank?
      elements.each do |el|
        el.children.each do |child|
          content = child.content
          add_metadata(element_label, content) if content.present? && el.attr('type') == type_value
        end
      end
    end

    def add_creator
      add_name_field('creator', 'creator')
    end

    def add_contributor
      add_name_field('contributor', 'advisor', type: 'Supervisor')
    end

    # @param type [String] This value must match as an element in the ContributorGroupService's
    #        authority.
    def add_name_field(name_field_prefix, element_name, type: nil)
      elements = record.xpath("//*[name()='#{element_name}']")
      return if elements.blank?
      position = 0
      elements.each do |el|
        el.children.each do |child|
          content = child.content
          names = content.split(/\s*;\s*/)
          next if names.blank?
          names.each do |name|
            separated_name = name.split(/\s*,\s*/)
            next if separated_name.blank?
            # @todo consier using https://rubygems.org/gems/namae for name parsing
            add_metadata("#{name_field_prefix}_family_name", (separated_name.first || ''), position)
            add_metadata("#{name_field_prefix}_given_name", (separated_name.length > 1 ? separated_name.last : ''), position)
            add_metadata("#{name_field_prefix}_name_type", 'Personal', position)
            add_metadata("#{name_field_prefix}_position", position, position)
            if type
              guard_type!(type)
              add_metadata("#{name_field_prefix}_type", type, position)
            end
            position += 1
          end
        end
      end
    end

    # @return [TrueClass] when the given type is valid
    # @raise [RuntimeError] when the given type is not valid
    #
    # @see ./app/views/shared/ubiquity/contributor/_edit_array_hash_form.html.erb The UI element
    #      that shows what is the range of values for the contributor_type field.
    def guard_type!(type)
      return true if ContributorGroupService.new.authority.find(type).present?

      raise "Expected type: #{type.inspect} to be present in ContributorGroupService authority."
    end
  end
end
