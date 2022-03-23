# Not an override
# Created to add the included module below to the CollectionForm
module Hyrax
  class CollectionForm < Hyrax::Forms::CollectionForm
    include ::Ubiquity::AllFormsSharedBehaviour
  end
end
