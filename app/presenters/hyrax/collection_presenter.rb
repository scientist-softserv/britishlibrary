# frozen_string_literal: true

# OVERRIDE here to add collection methods to collection presenter

require_dependency Hyrax::Engine.root.join('app', 'presenters', 'hyrax', 'collection_presenter').to_s

Hyrax::CollectionPresenter.class_eval do
  # Begin Featured Collections Methods
  def collection_featurable?
    user_can_feature_collection? && solr_document.public?
  end

  def display_feature_collection_link?
    collection_featurable? && FeaturedCollection.can_create_another? && !collection_featured?
  end

  def display_unfeature_collection_link?
    collection_featurable? && collection_featured?
  end

  def collection_featured?
    # only look this up if it's not boolean; ||= won't work here
    @collection_featured = FeaturedCollection.where(collection_id: solr_document.id).exists? if @collection_featured.nil?
    @collection_featured
  end

  def user_can_feature_collection?
    current_ability.can?(:create, FeaturedCollection)
  end
  # End Featured Collections Methods

  def terms_with_values
    self.class.terms.select do |t|
      value = self[t]
      value.is_a?(Array) ? value.first&.present? : value.present?
    end
  end
end
