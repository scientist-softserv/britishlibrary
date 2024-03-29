# frozen_string_literal: true

module Bulkrax::HasLocalProcessing
  # This method is called during build_metadata
  # add any special processing here, for example to reset a metadata property
  # to add a custom property from outside of the import data
  def add_local
    parsed_metadata['resource_type'] = ['ThesisOrDissertation Doctoral thesis'] if parser.is_a? Bulkrax::XmlEtdDcParser
    parsed_metadata['creator_search'] = parsed_metadata&.[]('creator_search')&.map { |c| c.values.join(', ') }
    parsed_metadata["qualification_name"] = set_qualification_name if parsed_metadata["qualification_name"]
    parsed_metadata['record_level_file_version_declaration'] = ActiveModel::Type::Boolean.new.cast parsed_metadata['record_level_file_version_declaration']
    set_institutional_relationships

    ['funder', 'creator', 'contributor', 'editor', 'alternate_identifier', 'related_identifier', 'current_he_institution'].each do |key|
      parsed_metadata[key] = [parsed_metadata[key].to_json] if parsed_metadata[key].present?
    end
  end

  def set_qualification_name
    if parsed_metadata['qualification_name'].gsub(/\s+/, "").downcase.tr('.', '').include?('phd')
      'PhD'
    else
      parsed_metadata['qualification_name']
    end
  end

  def set_institutional_relationships
    acceptable_values = {
      'researchassociate': 'Research associate',
      'staffmember': 'Staff member',
      'doctoralcollaborativestudent': 'Doctoral collaborative student'
    }

    # remove the invalid keys in the array below and use the `<object>_institional_relationship` key only
    ['contributor_researchassociate', 'contributor_staffmember', 'creator_researchassociate', 'creator_staffmember', 'editor_researchassociate', 'editor_staffmember'].each do |field|
      object, relationship = field.split('_')
      key = "#{object}_institutional_relationship"
      next if parsed_metadata[object].blank?
      parsed_metadata[object].each_with_index do |obj, index|
        next unless parsed_metadata&.[](object)&.[](index)
        # skip if no object or no object at index
        # if object and index are preset, but key is either nil or empty AND obj[field] is present, set the key
        if obj[field].present?
          if parsed_metadata[object][index][key]&.first.blank?
            parsed_metadata[object][index][key] = [acceptable_values[relationship.to_sym]]
          else
            parsed_metadata[object][index][key] << acceptable_values[relationship.to_sym]
          end
        end

        parsed_metadata&.[](object)&.[](index)&.delete(field)
      end
    end
  end
end
