# Generated via
#  `rails generate hyrax:work ThesisOrDissertation`
class ThesisOrDissertationIndexer < AppIndexer
  # Uncomment this block if you want to add custom indexing behavior:
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['ethos_access_rights_tesim'] = object.ethos_access_rights
    end
  end
end
