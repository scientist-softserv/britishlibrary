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
      # add_creator_isni
      # add language
      # etc

      self.parsed_metadata['file'] = self.raw_metadata['file']

      add_local
      raise StandardError, "title is required" if self.parsed_metadata['title'].blank?
      self.parsed_metadata
    end

    def complicated_elements
      %w(creator_isni creator_orcid doi language embargo_date alternate_identifier) # these are wrong use 'from' values
    end
  end
end

