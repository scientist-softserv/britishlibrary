module IiifPrint
  module MetadataDecorator
    private

    # BL has three special name fields that are split into
    # family name, given name, and also organization name
    # which need to be handled differently
    SPECIAL_NAME_FIELDS = [:creator, :contributor, :editor].freeze

    def values_for(field_name:)
      field_name = field_name.try(:name) || field_name
      values = Array(work["#{field_name}_tesim"] || work["#{field_name}_dtsi"]&.to_date.try(:to_formatted_s, :standard))
      return if values.empty?

      SPECIAL_NAME_FIELDS.include?(field_name) ? handle_names(field_name, values) : values
    end

    def handle_names(field_name, values)
      field = field_name.to_s
      names = JSON.parse(values.first)
      names.map do |hash|
        family_name = hash["#{field}_family_name"]
        given_name = hash["#{field}_given_name"]
        organization_name = hash["#{field}_organization_name"]

        [family_name, given_name, organization_name].compact.join(', ')
      end
    end
  end
end

IiifPrint::Metadata.prepend(IiifPrint::MetadataDecorator)
