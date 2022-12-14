# frozen_string_literal: true

require 'nokogiri'
module Bulkrax
  # Generic XML Entry
  class XmlEtdDcEntry < XmlEntry
    serialize :raw_metadata, JSON

    def factory_class
      'ThesisOrDissertation'.constantize
    end

    def build_metadata
      raise StandardError, 'Record not found' if record.nil?
      raise StandardError, "Missing source identifier (#{source_identifier})" if raw_metadata[source_identifier].blank?
      parsed_metadata = {}
      parsed_metadata[work_identifier] = [raw_metadata[source_identifier]]
      xml_elements.each do |element_name|
        next if complicated_elements.include?(element_name)
        elements = record.xpath("//*[name()='#{element_name}']")
        next if elements.blank?
        elements.each do |el|
          el.children.map(&:content).each do |content|
            add_metadata(element_name, content) if content.present?
          end
        end
      end
      add_model
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

    def add_complicated_fields
      add_authoridentifier
      add_subject
      add_identifier
      add_language
      # alt identifier
    end

    def add_authoridentifier
      add_complicated_element('authoridentifier_isni', 'authoridentifier', 'uketdterms:ISNI')
      add_complicated_element('authoridentifier_orcid', 'authoridentifier', 'uketdterms:ORCID')
    end

    def add_subject
      add_complicated_element('subject', 'subject', 'dcterms:Ddc')
    end

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
        el.children.map(&:content).each do |content|
          add_metadata(element_label, content) if content.present? && el.attr('type') == type_value
        end
      end
    end

    def add_fields_with_names
      add_creator
      add_contributor
      # etc
    end

    def add_creator
      add_name_field('creator', 'creator')
    end

    def add_contributor
      add_name_field('contributor', 'advisor')
    end

    def add_name_field(name_field_prefix, element_name)
      elements = record.xpath("//*[name()='#{element_name}']")
      return if elements.blank?
      position = 0
      elements.each do |el|
        el.children.map(&:content).each do |content|
          names = content.split(/\s*;\s*/)
          next if names.blank?
          names.each do |name|
            separated_name = name.split(/\s*,\s*/)
            next if separated_name.blank?
            add_metadata("#{name_field_prefix}_family_name", (separated_name.first || ''))
            add_metadata("#{name_field_prefix}_given_name", (separated_name.length > 1 ? separated_name.last : ''))
            add_metadata("#{name_field_prefix}_name_type", 'Personal')
            add_metadata("#{name_field_prefix}_position", position)
            position += 1
          end
        end
      end
    end

    def complicated_elements
      %w[authoridentifier_isni authoridentifier_orcid subject identifier language provenance source relation advisor creator] # maybe embargo_date
    end
  end
end
