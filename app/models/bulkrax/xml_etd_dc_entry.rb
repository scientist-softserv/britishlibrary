# frozen_string_literal: true

require 'nokogiri'
module Bulkrax
  # Generic XML Entry
  class XmlEtdDcEntry < XmlEntry
    serialize :raw_metadata, JSON

    def build_metadata
      raise StandardError, 'Record not found' if record.nil?
      raise StandardError, "Missing source identifier (#{source_identifier})" if self.raw_metadata[source_identifier].blank?
      self.parsed_metadata = {}
      self.parsed_metadata[work_identifier] = [self.raw_metadata[source_identifier]]
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
      add_visibility
      add_rights_statement
      add_admin_set_id
      add_collections
      add_authoridentifier
      add_subject
      add_identifier
      add_language
      # etc

      self.parsed_metadata['file'] = self.raw_metadata['file']

      add_local
      raise StandardError, "title is required" if self.parsed_metadata['title'].blank?
      self.parsed_metadata
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

    def complicated_elements
      %w(authoridentifier_isni authoridentifier_orcid subject identifier language provenance source relation) # maybe embargo_date
    end
  end
end

