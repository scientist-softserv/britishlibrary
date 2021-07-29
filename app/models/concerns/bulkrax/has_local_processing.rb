# frozen_string_literal: true

module Bulkrax::HasLocalProcessing
  # This method is called during build_metadata
  # add any special processing here, for example to reset a metadata property
  # to add a custom property from outside of the import data
  def add_local
    parsed_metadata['creator_search'] = parsed_metadata['creator_search'].map {|c| c.values.join(', ')}

    ['funder', 'creator', 'contributor', 'editor', 'alternate_identifier', 'related_identifier'].each do |key|
      parsed_metadata[key] = [parsed_metadata[key].to_json] if parsed_metadata[key].present?
    end
  end
end
