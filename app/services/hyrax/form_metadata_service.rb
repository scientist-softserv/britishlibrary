# copied over from Hyrax to make `rights_statement` multiple
module Hyrax
  # Answers queries about the cardinality of each field on the form.
  class FormMetadataService < HydraEditor::FieldMetadataService
    # @param [Class] model_class the class of the object
    # @param [Symbol] field the field we want to know about
    # @return [Boolean] true if the passed in field is a multivalued field
    def self.multiple?(model_class, field)
      case field.to_s
      when 'ordered_member_ids', 'in_works_ids', 'member_of_collection_ids', 'rights_statement'
        true
      else
        # Inquire at the model level
        super
      end
    end
  end
end
