# Not an override
# Created to add the included module below to the CollectionForm
module Hyrax
  class CollectionForm < Hyrax::Forms::CollectionForm
    include ::Ubiquity::AllFormsSharedBehaviour

    # return the terms from Hyrax::Forms::CollectionForm that are removed in ::Ubiquity::AllFormsSharedBehaviour
    self.terms += [:resource_type, :title, :creator, :contributor, :description,
      :keyword, :license, :publisher, :date_created, :subject, :language,
      :representative_id, :thumbnail_id, :identifier, :based_near,
      :related_url, :visibility, :collection_type_gid]
  end
end
