# TODO ~alignment: Bring over remaining methods from BL
module Ubiquity
  module SolrSearchDisplayHelpers

    #document is a solr document passed in from the view file
    def display_json_fields(document, field_name)
      attr_name = field_name.split('_').first
      if document.respond_to?(:solr_document)
        field_data =  document.solr_document[field_name] if (document.solr_document[field_name].present?)
        field = JSON.parse(field_data.first) if field_data.present?
        render "shared/ubiquity/search_display/show_array_hash", array_of_hash: field, attr_name: attr_name, document: document.solr_document
      else
        field_data =  document[field_name] if (document[field_name].present?)
        field = JSON.parse(field_data.first) if field_data.present?
        render "shared/ubiquity/search_display/show_array_hash", array_of_hash: field, attr_name: attr_name, document: document
      end
    end
  end
end
