# frozen_string_literal: true

module Bulkrax::HasLocalProcessing
  # This method is called during build_metadata
  # add any special processing here, for example to reset a metadata property
  # to add a custom property from outside of the import data
  def add_local
    parsed_metadata['creator_search'] = parsed_metadata&.[]('creator_search')&.map {|c| c.values.join(', ')}

    ['funder', 'creator', 'contributor', 'editor', 'alternate_identifier', 'related_identifier', 'current_he_institution'].each do |key|
      parsed_metadata[key] = [parsed_metadata[key].to_json] if parsed_metadata[key].present?
    end

    set_institutional_relationship
  end

  def set_institutional_relationship
    acceptable_values = {
      'researchassociate': 'Research associate',
      'staffmember': 'Staff member'
    }

    ['contributor_researchassociate', 'contributor_staffmember', 'creator_researchassociate', 'creator_staffmember', 'editor_researchassociate', 'editor_staffmember'].each do |field|
      if parsed_metadata[field].present?
        field_part, value_part = field.split('_')
        field_name = "#{field_part}_institutional_relationship"
        parsed_metadata[field_name] = acceptable_values[value_part]
        parsed_metadata.delete(field)
      end
    end
  end
end
