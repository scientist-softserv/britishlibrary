# frozen_string_literal: true

if Settings.bulkrax.enabled

  Bulkrax.setup do |config|
    # Add local parsers
    # config.parsers += []

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

    config.fill_in_blank_source_identifiers = ->(obj, index) { "#{Site.instance.account.name}-#{obj.importerexporter.id}-#{index}"}
    config.field_mappings['Bulkrax::CsvParser'] = {
      'abstract' => { from: ['abstract'], split: true },
      'access_control_id' => { excluded: true },
      'add_info' => { from: ['additional_information'], split: true },
      'admin_set_id' => { from: ['admin_set'], split: true },
      'alt_title' => { from: ['alternative_title'], split: true },
      'alternate_identifier' => { from: ['alternate_identifier'], object: 'alternate_identifier' },
      'alternate_identifier_type' => { from: ['alternate_identifier_type'], object: 'alternate_identifier' },
      'alternative_journal_title' => { from: ['alternative_journal_title'], split: true },
      'arkivo_checksum' => { excluded: true },
      'article_num' => { from: ['article_number'], split: true },
      'based_near' => { excluded: true },
      'bibliographic_citation' => { excluded: true },
      'book_title' => { from: ['book_title'], split: true },
      'bulkrax_identifier' => { from: ['bulkrax_identifier'], split: true, source_identifier: true },
      'collections' => { from: ['collection_id'], split: true },
      'contributor_family_name' => { from: ['contributor_family_name'], object: 'contributor' },
      'contributor_given_name' => { from: ['contributor_given_name'], object: 'contributor' },
      'contributor_grid' => { from: ['contributor_grid'], object: 'contributor' },
      'contributor_isni' => { from: ['contributor_isni'], object: 'contributor' },
      'contributor_name_type' => { from: ['contributor_name_type'], object: 'contributor' },
      'contributor_orcid' => { from: ['contributor_orcid'], object: 'contributor' },
      'contributor_organization_name' => { from: ['contributor_organization_name'], object: 'contributor' },
      'contributor_researchassociate' => { from: ['contributor_researchassociate'], object: 'contributor' },
      'contributor_ror' => { from: ['contributor_ror'], object: 'contributor' },
      'contributor_staffmember' => { from: ['contributor_staffmember'], object: 'contributor' },
      'contributor_type' => { from: ['contributor_type'], object: 'contributor' },
      'contributor_wikidata' => { from: ['contributor_wikidata'], object: 'contributor' },
      'creator_family_name' => { from: ['creator_family_name'], object: 'creator' },
      'creator_given_name' => { from: ['creator_given_name'], object: 'creator' },
      'creator_grid' => { from: ['creator_grid'], object: 'creator' },
      'creator_isni' => { from: ['creator_isni'], object: 'creator' },
      'creator_name_type' => { from: ['creator_name_type'], object: 'creator' },
      'creator_orcid' => { from: ['creator_orcid'], object: 'creator' },
      'creator_organization_name' => { from: ['creator_organization_name'], object: 'creator' },
      'creator_researchassociate' => { from: ['creator_researchassociate'], object: 'creator' },
      'creator_ror' => { from: ['creator_ror'], object: 'creator' },
      'creator_staffmember' => { from: ['creator_staffmember'], object: 'creator' },
      'creator_type' => { from: ['creator_type'], object: 'creator' },
      'creator_wikidata' => { from: ['creator_wikidata'], object: 'creator' },
      'current_he_institution' => { from: ['current_he_institution'], split: true },
      'date_accepted' => { from: ['date_accepted'], split: true },
      'date_published' => { from: ['date_published_1'], split: true },
      'date_submitted' => { from: ['date_submitted'], split: true },
      'depositor' => { excluded: true },
      'description' => { excluded: true },
      'dewey' => { from: ['dewey_classification'], split: true },
      'disable_draft_doi' => { excluded: true },
      'doi' => { from: ['doi'], split: true },
      'doi_options' => { excluded: true },
      'draft_doi' => { excluded: true },
      'duration' => { from: ['duration'], split: true },
      'edition' => { from: ['edition'], split: true },
      'editor_family_name' => { from: ['editor_family_name'], object: 'editor' },
      'editor_given_name' => { from: ['editor_given_name'], object: 'editor' },
      'editor_isni' => { from: ['editor_isni'], object: 'editor' },
      'editor_name_type' => { from: ['editor_name_type'], object: 'editor' },
      'editor_orcid' => { from: ['editor_orcid'], object: 'editor' },
      'editor_organization_name' => { from: ['editor_organization_name'], object: 'editor' },
      'editor_researchassociate' => { from: ['editor_researchassociate'], object: 'editor' },
      'editor_staffmember' => { from: ['editor_staffmember'], object: 'editor' },
      'eissn' => { from: ['eissn'], split: true },
      'embargo_id' => { excluded: true },
      'event_date' => { excluded: true },
      'event_location' => { from: ['event_location'], split: true },
      'event_title' => { from: ['event_title'], split: true },
      'file_availability' => { excluded: true },
      'file_url' => { from: ['file_url'], split: true },
      'fndr_project_ref' => { excluded: true },
      'funder_award' => { from: ['funder_award'], object: "funder", nested_type: 'Array' },
      'funder_doi' => { from: ['funder_doi'], object: "funder" },
      'funder_isni' => { from: ['funder_isni'], object: "funder" },
      'funder_name' => { from: ['funder_name'], object: "funder" },
      'funder_position' => { from: ['funder_position'], object: "funder" },
      'funder_ror' => { from: ['funder_ror'], object: "funder" },
      'head' => { excluded: true },
      'identifier' => { excluded: true },
      'institution' => { from: ['institution'], split: true },
      'isbn' => { from: ['isbn'], split: true },
      'issn' => { from: ['issn'], split: true },
      'issue' => { from: ['issue'], split: true },
      'journal_title' => { from: ['journal_title'], split: true },
      'keyword' => { from: ['keyword'], split: true },
      'label' => { excluded: true },
      'language' => { excluded: true },
      'lease_id' => { excluded: true },
      'library_of_congress_classification' => { from: ['library_of_congress_classification'], split: true },
      'license' => { from: ['license'], split: true },
      'media' => { from: ['material_media'], split: true },
      'model' => { from: ['work_type'], split: true },
      'official_link' => { from: ['official_url'], split: true },
      'on_behalf_of' => { excluded: true },
      'org_unit' => { from: ['organisational_unit'], split: true },
      'owner' => { excluded: true },
      'pagination' => { from: ['pagination'], split: true },
      'place_of_publication' => { from: ['place_of_publication'], split: true },
      'project_name' => { from: ['project_name'], split: true },
      'proxy_depositor' => { excluded: true },
      'publisher' => { from: ['publisher'], split: true },
      'qualification_level' => { from: ['qualification_level'], split: true },
      'qualification_name' => { from: ['qualification_name'], split: true },
      'refereed' => { from: ['peer_reviewed'], split: true },
      'related_exhibition' => { from: ['related_exhibition'], split: true },
      'related_exhibition_date' => { excluded: true },
      'related_exhibition_venue' => { from: ['related_exhibition_venue'], split: true },
      'related_identifier' => { from: ['related_identifier'], object: 'related_identifier' },
      'related_identifier_type' => { from: ['related_identifier_type'], object: 'related_identifier' },
      'related_url' => { from: ['related_url'], split: true },
      'relation_type' => { from: ['relation_type'], object: 'related_identifier' },
      'relative_path' => { excluded: true },
      'rendering_ids' => { excluded: true },
      'representative_id' => { excluded: true },
      'resource_type' => { from: ['resource_type'], split: true },
      'rights_holder' => { from: ['rights_holder'], split: true },
      'rights_statement' => { from: ['rights_statement'], split: true },
      'series_name' => { from: ['series_name'], split: true },
      'source' => { excluded: true },
      'state' => { excluded: true },
      'subject' => { excluded: true },
      'tail' => { excluded: true },
      'thumbnail_id' => { excluded: true },
      'title' => { from: ['title'], split: true },
      'version' => { from: ['version'], split: true },
      'version_number' => { excluded: true },
      'volume' => { from: ['volume'], split: true }
    }



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
