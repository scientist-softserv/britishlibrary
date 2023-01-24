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
    # @params data [String] The "data" value for the #raw_metadata of the {Bulkrax::Entry}.
    # @params parser_class_name [String] One of the the named parsers of {Bulkrax.parsers}
    # @params entry_class [Class<Bulkrax::Entry>]
    #
    # @return [Bulkrax::Entry]
    #
    # @todo Extract this method back into a Bulkrax::SpecHelper module.
    # @todo This could replace some of the factories in Bulkrax's spec suite.
    # @note This presently assumes as CSV oriented format; or "We haven't checked this against CSV".
    #       And the signature of this method should be considered volatile.
    def self.build_csv_entry_for(identifier:, data:, parser_class_name:, entry_class:)
      import_file_path = Rails.root.join("spec", "fixtures", "csv", "british-library.csv")
      importer = Bulkrax::Importer.new(
        name: "Test importer for identifier #{identifier}",
        admin_set_id: "admin_set/default",
        user_id: 1,
        limit: 1,
        parser_klass: parser_class_name,
        field_mapping: Bulkrax.field_mappings.fetch(parser_class_name),
        parser_fields: { 'import_file_path' => import_file_path }
      )

      entry_class.new(
        importerexporter: importer,
        identifier: identifier,
        raw_metadata: data
      )
    end
  end
end

RSpec.describe Bulkrax::CsvEntry do
  describe "#build_metadata" do
    subject(:entry) do
      Bulkrax::SpecHelper.build_csv_entry_for(
        data: data,
        identifier: identifier,
        parser_class_name: 'Bulkrax::CsvParser',
        entry_class: described_class
      )
    end

    let(:identifier) { 'bl-26-0' }
    let(:data) do
      {
        work_type: "Book",
        resource_type: "Article default Journal article",
        title: %(Can I believe what I see? Data visualisation and trust in the humanities Imported by GJ 23/01/23),
        creator_name_type_1: "Personal",
        creator_family_name_1: "Boyd Davis",
        creator_given_name_1: "Stephen",
        creator_orcid_1: "0000-0002-5391-4557",
        creator_name_type_2: "Personal",
        creator_family_name_2: "Vane",
        creator_given_name_2: "Olivia",
        creator_orcid_2: "0000-0002-3777-4910",
        creator_staffmember_2: "TRUE",
        creator_name_type_3: "Personal",
        creator_family_name_3: "Kräutli",
        creator_given_name_3: "Florian",
        creator_orcid_3: "0000-0001-9039-0900",
        abstract: %(Questions of trust are increasingly important in relation to data and its use.),
        date_published: "12/10/2021",
        institution_1: "British Library",
        organisational_unit_1: "Digital Scholarship",
        journal_title: "Interdisciplinary Science Reviews",
        volume_1: 46,
        issue: 4,
        pagination: "522-546",
        publisher_1: "Taylor and Francis",
        place_of_publication_1: "UK",
        issn: "0308-0188",
        eissn: "1743-2790",
        date_accepted: "12/09/2020",
        official_url: "https://doi.org/10.1080/03080188.2021.1872874",
        language_1: "English",
        license_1: "https://creativecommons.org/licenses/by-nd/4.0/",
        rights_statement: "http://rightsstatements.org/vocab/InC/1.0/",
        rights_holder_1: "",
        doi: "10.1080/03080188.2021.1872874",
        bulkrax_identifier: identifier
      }
    end

    it "assigns factory_class and parsed_metadata" do
      entry.build_metadata
      expect(entry.factory_class).to eq(Book)
    end
  end
end
