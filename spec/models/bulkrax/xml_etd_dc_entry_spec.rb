# frozen_string_literal: true

require "spec_helper"

module Bulkrax
  module SpecHelper
    ##
    # @api private
    #
    # A spec helper method for building Bulrax::Entry instances in downstream bulkrax applications.
    #
    # @params identifier [#to_s] The identifier of this object
    # @params adata [String] The "data" value for the #raw_metadata of the {Bulkrax::Entry}.
    # @params parser_class_name [String] One of the the named parsers of {Bulkrax.parsers}
    # @params entry_class [Class<Bulkrax::Entry>]
    # @param collection [Array<String>]
    # @param children [Array<String>]
    #
    # @return [Bulkrax::Entry]
    #
    # @todo Extract this method back into a Bulkrax::SpecHelper module.
    # @todo This could replace some of the factories in Bulkrax's spec suite.
    # @note This presently assumes an XML oriented format; or "We haven't checked this against CSV".
    #       And the signature of this method should be considered volatile.
    #
    # rubocop:disable Metrics/ParameterLists
    def self.build_entry_for(identifier:, data:, parser_class_name:, entry_class:, collection: [], children: [])
      importer = Bulkrax::Importer.new(
        name: "Test importer for identifier #{identifier}",
        admin_set_id: "admin_set/default",
        user_id: 1,
        limit: 1,
        parser_klass: parser_class_name,
        field_mapping: Bulkrax.field_mappings.fetch(parser_class_name),
        parser_fields: {}
      )

      raw_metadata = {
        importer.parser.source_identifier.to_s => identifier,
        "data" => data,
        "collection" => collection,
        "children" => children
      }

      entry_class.new(
        importerexporter: importer,
        identifier: identifier,
        raw_metadata: raw_metadata
      )
    end
    # rubocop:enable Metrics/ParameterLists
  end
end

RSpec.describe Bulkrax::XmlEtdDcEntry do
  # To run this fast in Docker:
  #
  # 1. spring start
  # 2. spring rspec spec/models/bulkrax/xml_etd_dc_entry_spec.rb
  describe "#build_metadata" do
    context "source http://ethos.bl.uk/ProcessSearch.do?query=709645" do
      subject(:entry) do
        Bulkrax::SpecHelper.build_entry_for(
          entry_class: described_class,
          identifier: identifier,
          data: data,
          parser_class_name: "Bulkrax::XmlEtdDcParser"
        )
      end

      let(:identifier) { "http://ethos.bl.uk/ProcessSearch.do?query=709645" }
      let(:data) do
        %(
           <uketddc schemaLocation="http://naca.central.cranfield.ac.uk/ethos-oai/2.0/ http://naca.central.cranfield.ac.uk/ethos-oai/2.0/uketd_dc.xsd">
             <creator>Hasikou, Anastasia</creator>
             <authoridentifier type="uketdterms:ISNI">0000000460594066</authoridentifier>
             <issued>01/01/2017</issued>
             <subject type="dcterms:Ddc">780.95693</subject>
             <coverage>M Music</coverage>
             <abstract>This thesis examines relationships between the music of the Greek community of Cyprus and the social...</abstract>
             <language type="dcterms:ISO639-2">eng</language>
             <institution>City, University of London</institution>
             <publisher>City, University of London</publisher>
             <title>The social history of music development in the Greek Cypriot population during 1878-1945</title>
             <type>Thesis (Ph.D.)</type>
             <qualificationlevel>doctoral</qualificationlevel>
             <isReferencedBy>https://openaccess.city.ac.uk/id/eprint/17030/</isReferencedBy>
             <source>http://ethos.bl.uk/ProcessSearch.do?query=709645</source>
             <relation>018328594</relation>
             <department>Department of Music</department>
             <accessRights>true</accessRights>
             <provenance>oai:openaccess.city.ac.uk:17030</provenance>
           </uketddc>
        )
      end

      it "assigns parsed_metadata" do
        entry.build_metadata

        expect(entry.parsed_metadata.fetch('publisher')).to eq(["City, University of London"])
        expect(entry.parsed_metadata.fetch('title')).to eq(["The social history of music development in the Greek Cypriot population during 1878-1945"])
        expect(entry.parsed_metadata.fetch('model')).to eq('ThesisOrDissertation')
        expect(entry.parsed_metadata.fetch('source')).to eq(['M Music'])
        expect(entry.factory_class).to eq(ThesisOrDissertation)
      end
    end
  end
end
