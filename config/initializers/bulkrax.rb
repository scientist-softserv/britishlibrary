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
    # config.system_identifier_field = 'source'

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

      # 'based_near' => { from: ['location'], split: '\|' },
      # 'contributor' => { from: ['contributor'], split: '\|' },
      # 'creator' => { from: ['creator'], split: '\|' },
      # 'date_created' => { from: ['date_created'], split: '\|' },
      # 'description' => { from: ['description'], split: '\|' },
      # 'file' => { from: ['item'], split: '\|' }
      # 'identifier' => { from: ['identifier'], split: '\|' },
      # 'keyword' => { from: ['keyword'], split: '\|' },
      # 'language' => { from: ['language'], split: '\|' },
      # 'license' => { from: ['license'], split: '\|' },
      # 'publisher' => { from: ['publisher'], split: '\|' },
      # 'related_url' => { from: ['related_url'], split: '\|' },
      # 'resource_type' => { from: ['type'], split: '\|' },
      # 'subject' => { from: ['subject'], split: '\|' },
      # 'title' => { from: ['title'], split: '\|' },
    }

    config.field_mappings['Bulkrax::CsvParser'] = basic_csv_mappings

    config.field_mappings['Bulkrax::ArticleCsvParser'] = basic_csv_mappings.merge({
      'abstract' => { from: ['abstract'], split: '\|' },
      # 'access_control_id' => { from: ['access_control_id'], split: '\|' },
      'add_info' => { from: ['additional_information'], split: '\|' },
      # 'admin_set_id' => { from: ['admin_set_id'], split: '\|' },
      # 'alt_title' => { from: ['alternative_title'], split: '\|' },
      # 'alternate_identifier' => { from: ['alternate_identifier'], split: '\|' },
      # 'alternate_identifier_type' ... # numbered
      'alternative_journal_title' => { from: ['alternative_journal_title'], split: '\|' },
      # 'arkivo_checksum' => { from: ['arkivo_checksum'], split: '\|' },
      # 'article_num' => { from: ['article_number'], split: '\|' },
      # 'based_near' => { from: ['based_near'], split: '\|' },
      # 'bibliographic_citation' => { from: ['bibliographic_citation'], split: '\|' },
      # 'book_title' => { from: ['book_title'], split: '\|' },
      # 'collection_id' => { from: ['collection_id'], split: '\|' },
      # 'collection_names' => { from: ['collection_names'], split: '\|' },
      # 'contributor' => { from: ['contributor'], split: '\|' },
          # 'contributor_family_name' # numbered
          # 'contributor_given_name' # numbered
          # 'contributor_grid' # numbered
          # 'contributor_isni' # numbered
          # 'contributor_name_type' # numbered
          # 'contributor_orchid' # numbered
          # 'contributor_organization_name' # numbered
          # 'contributor_researchassociate' # numbered
          # 'contributor_staffmember' # numbered
          # 'contributor_type' # numbered
          # 'contributor_wikidata' # numbered
      # 'creator' => { from: ['creator'], split: '\|' },
      # 'creator_search' => { from: ['creator_search'], split: '\|' },
      # 'current_he_institution' => { from: ['current_he_institution'], split: '\|' },
      'date_accepted' => { from: ['date_accepted'], split: '\|' },
      # 'date_modified' => { from: ['date_modified'], split: '\|' },
      # 'date_published' => { from: ['date_published_1'], split: '\|' },
      'date_submitted' => { from: ['date_submitted'], split: '\|' },
      # 'date_uploaded' => { from: ['date_uploaded'], split: '\|' },
      # 'depositor' => { from: ['depositor'], split: '\|' },
      # 'description' => { from: ['description'], split: '\|' },
      'dewey' => { from: ['dewey_classification'], split: '\|' },
      # 'disable_draft_doi' => { from: ['disable_draft_doi'], split: '\|' },
      'doi' => { from: ['doi'], split: '\|' },
      # 'doi_options' => { from: ['doi_options'], split: '\|' },
      # 'draft_doi' => { from: ['draft_doi'], split: '\|' },
      # 'duration' => { from: ['duration'], split: '\|' },
      # 'edition' => { from: ['edition'], split: '\|' },
      # 'editor' => { from: ['editor'], split: '\|' },
      'eissn' => { from: ['eissn'], split: '\|' },
      # 'embargo_id' => { from: ['embargo_id'], split: '\|' },
      # # 'embargo_end_date' # yes
      # 'event_date' => { from: ['event_date'], split: '\|' },
      # 'event_location' => { from: ['event_location'], split: '\|' },
      # 'event_title' => { from: ['event_title'], split: '\|' },
      # # 'file' # numbered
      # 'file_availability' => { from: ['file_availability'], split: '\|' },
      # 'fndr_project_ref' => { from: ['funder_project_reference'], split: '\|' },
      # 'funder' => { from: ['funder_name'], split: '\|' },
      # 'head' => { from: ['head'], split: '\|' },
      # 'id' => { from: ['id'], split: '\|' },
      # 'identifier' => { from: ['identifier'], split: '\|' },
      # 'import_url' => { from: ['import_url'], split: '\|' },
      # 'institution' => { from: ['institution'], split: '\|' },
      # 'isbn' => { from: ['isbn'], split: '\|' },
      'issn' => { from: ['issn'], split: '\|' },
      'issue' => { from: ['issue'], split: '\|' },
      'journal_title' => { from: ['journal_title'], split: '\|' },
      # 'keyword' => { from: ['keyword'], split: '\|' },
      # 'label' => { from: ['label'], split: '\|' },
      # 'language' => { from: ['language'], split: '\|' },
      # 'lease_id' => { from: ['lease_id'], split: '\|' },
      # 'lease_end_date' # yes
      'library_of_congress_classification' => { from: ['library_of_congress_classification'], split: '\|' },
      # 'license' => { from: ['license'], split: '\|' },
      # 'media' => { from: ['media'], split: '\|' },
      # 'official_link' => { from: ['official_url'], split: '\|' },
      # 'on_behalf_of' => { from: ['on_behalf_of'], split: '\|' },
      # 'org_unit' => { from: ['organisational_unit'], split: '\|' },
      # 'owner' => { from: ['owner'], split: '\|' },
      'pagination' => { from: ['pagination'], split: '\|' },
      # 'peer_reviewed' # yes
      # 'place_of_publication' => { from: ['place_of_publication'], split: '\|' },
      # 'project_name' => { from: ['project_name'], split: '\|' },
      # 'proxy_depositor' => { from: ['proxy_depositor'], split: '\|' },
      'publisher' => { from: ['publisher'], split: '\|' },
      # 'qualification_level' => { from: ['qualification_level'], split: '\|' },
      # 'qualification_name' => { from: ['qualification_name'], split: '\|' },
      # 'refereed' => { from: ['refereed'], split: '\|' },
      # 'related_exhibition' => { from: ['related_exhibition'], split: '\|' },
      # 'related_exhibition_date' => { from: ['related_exhibition_date'], split: '\|' },
      # 'related_exhibition_venue' => { from: ['related_exhibition_venue'], split: '\|' },
      # 'related_identifier' => { from: ['related_identifier'], split: '\|' },
      # # 'related_identifier_type' ... # numbered
      # # 'relation_type' ... # numbered
      # 'related_url' => { from: ['related_url'], split: '\|' },
      # 'relative_path' => { from: ['relative_path'], split: '\|' },
      # 'rendering_ids' => { from: ['rendering_ids'], split: '\|' },
      # 'representative_id' => { from: ['representative_id'], split: '\|' },
      # 'resource_type' => { from: ['resource_type'], split: '\|' },
      # 'rights_holder' => { from: ['rights_holder'], split: '\|' },
      'rights_statement' => { from: ['rights_statement'], split: '\|' },
      # 'series_name' => { from: ['series_name'], split: '\|' },
      # 'source' => { from: ['source'], split: '\|' },
      # 'state' => { from: ['state'], split: '\|' },
      # 'subject' => { from: ['subject'], split: '\|' },
      # 'tail' => { from: ['tail'], split: '\|' },
      # 'thumbnail_id' => { from: ['thumbnail_id'], split: '\|' },
      'title' => { from: ['title'], split: '\|' },
      # 'version' => { from: ['version'], split: '\|' },
      # 'version_number' => { from: ['version_number'], split: '\|' },
      # visibility # yes
      'volume' => { from: ['volume'], split: '\|' },
      # 'work_type' # yes
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
