class CollectionIndexJob < Hyrax::ApplicationJob
  def perform(collection_id)
    c = Collection.find(collection_id)
    c&.update_index
  end
end
