# frozen_string_literal: true

if Settings.bulkrax.enabled

  Bulkrax.setup do |config|
    # Add local parsers
    config.parsers += [
      # { name: 'MODS - My Local MODS parser', class_name: 'Bulkrax::ModsXmlParser', partial: 'mods_fields'},
      { name: 'CSV - Article', class_name: 'Bulkrax::ArticleCsvParser', partial: 'csv_fields' }
    ]

    # Field to use during import to identify if the Work or Collection already exists.
    # Default is 'source'.
    # field used to look up the result of a work (what's used by the "find" method)
    config.system_identifier_field = 'doi'

    # Field_mapping for establishing the source_identifier
    # This value IS NOT used for OAI, so setting the OAI Entries here will have no effect
    # The mapping is supplied per Entry, provide the full class name as a string, eg. 'Bulkrax::CsvEntry'
    # Example:
    #   {
    #     'Bulkrax::RdfEntry'  => 'http://opaquenamespace.org/ns/identifier',
    #     'Bulkrax::CsvEntry'  => 'MyIdentifierField'
    #   }
    # The default value for CSV is 'source_identifier'
    # which csv field are we setting as the source_identifier?
    config.source_identifier_field_mapping = {
      'Bulkrax::ArticleCsvEntry' => 'doi'
    }

    # WorkType to use as the default if none is specified in the import
    # Default is the first returned by Hyrax.config.curation_concerns
    # config.default_work_type = MyWork

    # Path to store pending imports
    # config.import_path = 'tmp/imports'

    # Path to store exports before download
    # config.export_path = 'tmp/exports'

    # Server name for oai request header
    # config.server_name = 'my_server@name.com'

    # Field_mapping for establishing a parent-child relationship (FROM parent TO child)
    # This can be a Collection to Work, or Work to Work relationship
    # This value IS NOT used for OAI, so setting the OAI Entries here will have no effect
    # The mapping is supplied per Entry, provide the full class name as a string, eg. 'Bulkrax::CsvEntry'
    # Example:
    #   {
    #     'Bulkrax::RdfEntry'  => 'http://opaquenamespace.org/ns/contents',
    #     'Bulkrax::CsvEntry'  => 'children'
    #   }
    # By default no parent-child relationships are added
    # config.parent_child_field_mapping = { }

    # Field_mapping for establishing a collection relationship (FROM work TO collection)
    # This value IS NOT used for OAI, so setting the OAI parser here will have no effect
    # The mapping is supplied per Entry, provide the full class name as a string, eg. 'Bulkrax::CsvEntry'
    # The default value for CSV is collection
    # Add/replace parsers, for example:
    # config.collection_field_mapping['Bulkrax::RdfEntry'] = 'http://opaquenamespace.org/ns/set'

    # Field mappings
    # Create a completely new set of mappings by replacing the whole set as follows
    #   config.field_mappings = {
    #     'Bulkrax::OaiDcParser' => { **individual field mappings go here*** }
    #   }

    basic_csv_mappings = {
      # TODO(alishaevn): move the overlapping values from all parser's here

      # 'based_near' => { from: ['location'] },
      # 'contributor' => { from: ['contributor'] },
      # 'creator' => { from: ['creator'] },
      # 'date_created' => { from: ['date_created'] },
      # 'description' => { from: ['description'] },
      # 'file' => { from: ['item'] }
      # 'identifier' => { from: ['identifier'] },
      # 'keyword' => { from: ['keyword'] },
      # 'language' => { from: ['language'] },
      # 'license' => { from: ['license'] },
      # 'publisher' => { from: ['publisher'] },
      # 'related_url' => { from: ['related_url'] },
      # 'resource_type' => { from: ['type'] },
      # 'subject' => { from: ['subject'] },
      # 'title' => { from: ['title'] },
    }

    config.field_mappings['Bulkrax::CsvParser'] = basic_csv_mappings

    # TODO(alishaevn):
      # - customize contributor and creator to the following format: "object_name"=> ["[{...}, {...}]"]
        # unsure if editor needs the same configuration
      # - update "funder" after bulkrax can handle nested objects
    config.field_mappings['Bulkrax::ArticleCsvParser'] = basic_csv_mappings.merge({
      'abstract' => { from: ['abstract'] },
      'access_control_id' => { excluded: true },
      'add_info' => { from: ['additional_information'] },
      'admin_set_id' => { from: ['admin_set'] },
      'alt_title' => { from: ['alternative_title'] },
      'alternate_identifier' => { from: ['alternate_identifier'] },
      'alternate_identifier_type' => { from: ['alternate_identifier_type'] },
      'alternative_journal_title' => { from: ['alternative_journal_title'] },
      'arkivo_checksum' => { excluded: true },
      'article_num' => { from: ['article_number'] },
      'based_near' => { excluded: true },
      'bibliographic_citation' => { excluded: true },
      'book_title' => { from: ['book_title'] },
      'collection_id' => { from: ['collection_id'] },
      'collection_names' => { excluded: true },
      # "contributor_name_type" => { from: ["contributor_name_type"], object: "contributor" },
      # "contributor_family_name" => { from: ["contributor_family_name"], object: "contributor" },
      # "contributor_given_name" => { from: ["contributor_given_name"], object: "contributor" },
      # "contributor_orcid" => { from: ["contributor_orcid"], object: "contributor" },
      # "contributor_isni" => { from: ["contributor_isni"], object: "contributor" },
      # "contributor_grid" => { from: ["contributor_grid"], object: "contributor" },
      # "contributor_organization_name" => { from: ["contributor_organization_name"], object: "contributor" },
      # "contributor_researchassociate" => { from: ["contributor_researchassociate"], object: "contributor" },
      # "contributor_ror" => { from: ["contributor_ror"], object: "contributor" },
      # "contributor_staffmember" => { from: ["contributor_staffmember"], object: "contributor" },
      # "contributor_type" => { from: ["contributor_type"], object: "contributor" },
      # "contributor_wikidata" => { from: ["contributor_wikidata"], object: "contributor" },
      # "creator_name_type" => { from: ["creator_name_type"], object: "creator" },
      # "creator_family_name" => { from: ["creator_family_name"], object: "creator" },
      # "creator_given_name" => { from: ["creator_given_name"], object: "creator" },
      # "creator_grid" => { from: ["creator_grid"], object: "creator" },
      # "creator_orcid" => { from: ["creator_orcid"], object: "creator" },
      # "creator_organization_name" => { from: ["creator_organization_name"], object: "creator" },
      # "creator_isni" => { from: ["creator_isni"], object: "creator" },
      # "creator_researchassociate" => { from: ["creator_researchassociate"], object: "creator" },
      # "creator_ror" => { from: ["creator_ror"], object: "creator" },
      # "creator_staffmember" => { from: ["creator_staffmember"], object: "creator" },
      # "creator_type" => { from: ["creator_type"], object: "creator" },
      # "creator_wikidata" => { from: ["creator_wikidata"], object: "creator" },
      # "creator_family_name" => { from: ["creator_family_name"], object: "creator_search" },
      # "creator_given_name" => { from: ["creator_given_name"], object: "creator_search" },
      'current_he_institution' => { from: ['current_he_institution'] },
      'date_accepted' => { from: ['date_accepted'] },
      'date_modified' => { from: ['date_modified'] },
      'date_published' => { from: ['date_published_1'] },
      'date_submitted' => { from: ['date_submitted'] },
      'date_uploaded' => { from: ['date_uploaded'] },
      'depositor' => { excluded: true },
      'description' => { excluded: true },
      'dewey' => { from: ['dewey_classification'] },
      'disable_draft_doi' => { excluded: true },
      'doi' => { from: ['doi'] },
      'doi_options' => { excluded: true },
      'draft_doi' => { excluded: true },
      'duration' => { from: ['duration'] },
      'edition' => { from: ['edition'] },
      # 'editor' => { from: ['editor'] },
      'eissn' => { from: ['eissn'] },
      'embargo_id' => { excluded: true },
      'event_date' => { excluded: true },
      'event_location' => { from: ['event_location'] },
      'event_title' => { from: ['event_title'] },
      'file_availability' => { excluded: true },
      'fndr_project_ref' => { excluded: true },
      # 'funder' => { from: ['funder_name'] },
      'head' => { excluded: true },
      'id' => { from: ['id'] },
      'identifier' => { excluded: true },
      'institution' => { from: ['institution'] },
      'isbn' => { from: ['isbn'] },
      'issn' => { from: ['issn'] },
      'issue' => { from: ['issue'] },
      'journal_title' => { from: ['journal_title'] },
      'keyword' => { from: ['keyword'] },
      'label' => { excluded: true },
      'language' => { excluded: true },
      'lease_id' => { excluded: true },
      'library_of_congress_classification' => { from: ['library_of_congress_classification'] },
      'license' => { from: ['license'] },
      'media' => { from: ['material_media'] },
      'official_link' => { from: ['official_url'] },
      'on_behalf_of' => { excluded: true },
      'org_unit' => { from: ['organisational_unit'] },
      'owner' => { excluded: true },
      'pagination' => { from: ['pagination'] },
      'place_of_publication' => { from: ['place_of_publication'] },
      'project_name' => { from: ['project_name'] },
      'proxy_depositor' => { excluded: true },
      'publisher' => { from: ['publisher'] },
      'qualification_level' => { from: ['qualification_level'] },
      'qualification_name' => { from: ['qualification_name'] },
      'refereed' => { from: ['peer_reviewed'] },
      'related_exhibition' => { from: ['related_exhibition'] },
      'related_exhibition_date' => { excluded: true },
      'related_exhibition_venue' => { from: ['related_exhibition_venue'] },
      "related_identifier" => { from: ["related_identifier"], object: "related_identifier" }
      "related_identifier_type" => { from: ["related_identifier_type"], object: "related_identifier" }
      "relation_type" => { from: ["relation_type"], object: "related_identifier" }
      'related_url' => { from: ['related_url'] },
      'relative_path' => { excluded: true },
      'rendering_ids' => { excluded: true },
      'representative_id' => { excluded: true },
      'resource_type' => { from: ['resource_type'] },
      'rights_holder' => { from: ['rights_holder'] },
      'rights_statement' => { from: ['rights_statement'] },
      'series_name' => { from: ['series_name'] },
      'source' => { excluded: true },
      'state' => { excluded: true },
      'subject' => { excluded: true },
      'tail' => { excluded: true },
      'thumbnail_id' => { excluded: true },
      'title' => { from: ['title'] },
      'version' => { from: ['version'] },
      'version_number' => { excluded: true },
      'volume' => { from: ['volume'] },
    })



    # Add to, or change existing mappings as follows
    #   e.g. to exclude date
    #   config.field_mappings['Bulkrax::OaiDcParser']['date'] = { from: ['date'], excluded: true  }

    # To duplicate a set of mappings from one parser to another
    #   config.field_mappings['Bulkrax::OaiOmekaParser'] = {}
    #   config.field_mappings['Bulkrax::OaiDcParser'].each {|key,value| config.field_mappings['Bulkrax::OaiOmekaParser'][key] = value }

    # Properties that should not be used in imports/exports. They are reserved for use by Hyrax.
    # config.reserved_properties += ['my_field']
  end
end

# OBJECT WITH MULTIPLES
# "creator"=> ["[
#   {
#     "creator_given_name":"Creator given name 1",
#     "creator_family_name":"Creator family name 1",
#     "creator_name_type":"Personal",
#     "creator_orcid":"reator1",
#     "creator_isni":"reator1",
#     "creator_position":"0",
#     "creator_institutional_relationship":["Staff member"]
#   }, {
#     "creator_given_name":"Creator given name 2",
#     "creator_family_name":"Creator family name 2",
#     "creator_name_type":"Personal",
#     "creator_orcid":"reator2",
#     "creator_isni":"reator2",
#     "creator_position":"1",
#     "creator_institutional_relationship":["Research associate"]
#   }, {
#     "creator_organization_name":"Creator organisation name 3",
#     "creator_name_type":"Organisational",
#     "creator_isni":"reator3",
#     "creator_ror":"www.Creator-organisation-ROR-3.com",
#     "creator_grid":"www.Creator-organisation-GRID-3.com",
#     "creator_wikidata":"www.Creator-organisation-Wikidata-3.com",
#     "creator_position":"2"
#   }
# ]"]

# OBJECT WITH SINGLE VALUE
# "creator"=> ["[
#   {
#     "creator_given_name":"Creator given name 1",
#     "creator_family_name":"Creator family name 1",
#     "creator_name_type":"Personal",
#     "creator_orcid":"reator1",
#     "creator_isni":"reator1",
#     "creator_position":"1",
#     "creator_institutional_relationship":["Staff member"]
#   }
# ]"]