class ArticleIndexer < SharedIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  # Uncomment this block if you want to add custom indexing behavior:
  def generate_solr_document
   super.tap do |solr_doc|
    solr_doc['year_published_isi'] = object.date_published[0...4].to_i if object.date_published.present?
   end
  end
end
