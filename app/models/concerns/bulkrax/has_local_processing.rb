# frozen_string_literal: true

module Bulkrax::HasLocalProcessing
  # This method is called during build_metadata
  # add any special processing here, for example to reset a metadata property
  # to add a custom property from outside of the import data
  def add_local
    parsed_metadata['creator_search'] = parsed_metadata&.[]('creator_search')&.map { |c| c.values.join(', ') }
    set_institutional_relationships

    ['funder', 'creator', 'contributor', 'editor', 'alternate_identifier', 'related_identifier', 'current_he_institution'].each do |key|
      parsed_metadata[key] = [parsed_metadata[key].to_json] if parsed_metadata[key].present?
    end
  end

  def set_institutional_relationships
    acceptable_values = {
      'researchassociate': 'Research associate',
      'staffmember': 'Staff member'
    }

    # remove the invalid keys in the array below and use the `<object>_institional_relationship` key only
    ['contributor_researchassociate', 'contributor_staffmember', 'creator_researchassociate', 'creator_staffmember', 'editor_researchassociate', 'editor_staffmember'].each do |field|
      object, relationship = field.split('_')
      key = "#{object}_institutional_relationship"

      parsed_metadata[object].each_with_index do |obj, index|
        unless parsed_metadata[object][index][key].first.present?
          parsed_metadata[object][index][key] = acceptable_values[relationship.to_sym] if obj[field].present?
        end

        parsed_metadata[object][index].delete(field)
      end
    end
  end
end
