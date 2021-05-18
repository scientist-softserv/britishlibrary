# TODO ~alignment: Bring over remaining methods from BL
module Ubiquity
  module SolrSearchDisplayHelpers

    #doc is a solr document passed in from the view file
    def display_json_fields(doc, field_name)
      attr_name = field_name.split('_').first
      field_data =  doc[field_name] if (doc[field_name].present?)
      field = JSON.parse(field_data.first) if field_data.present?
      render "shared/ubiquity/search_display/show_array_hash", array_of_hash: field, attr_name: attr_name
    end
  end
end
