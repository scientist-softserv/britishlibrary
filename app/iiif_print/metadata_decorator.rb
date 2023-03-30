module IiifPrint
  module MetadataDecorator
    private

      def faceted_values_for(field_name:)
        values_for(field_name: field_name).map do |value|
          # In BL, creator facet is `creator_search_sim`
          search_field = field_name == :creator ? field_name.to_s + "_search_sim" : field_name.to_s + "_sim"
          path = Rails.application.routes.url_helpers.search_catalog_path(
            "f[#{search_field}][]": value, locale: I18n.locale
          )
          path += '&include_child_works=true' if work["is_child_bsi"] == true
          "<a href='#{File.join(@base_url, path)}'>#{value}</a>"
        end
      end

      # BL has three special name fields that are split into
      # family name, given name, and also organization name
      # which need to be handled differently
      SPECIAL_NAME_FIELDS = [:creator, :contributor, :editor].freeze

      def values_for(field_name:)
        field_name = field_name.try(:name) || field_name
        values = Array(work["#{field_name}_tesim"] || work["#{field_name}_dtsi"]&.to_date.try(:to_formatted_s, :standard))
        return if values.empty?

        if SPECIAL_NAME_FIELDS.include?(field_name)
          handle_names(field_name, values)
        elsif field_name == :funder
          handle_funder(values)
        elsif field_name == :alternate_identifier
          handle_alternative_identifier(values)
        elsif field_name == :related_identifier
          handle_related_identifier(values)
        elsif field_name == :resource_type
          handle_resource_type(values)
        else
          values
        end
      end

      def handle_names(field_name, values)
        field = field_name.to_s
        names = JSON.parse(values.first)
        names.map do |hash|
          family_name_key = "#{field}_family_name"
          given_name_key = "#{field}_given_name"
          organization_name_key = "#{field}_organization_name"

          family_name = hash[family_name_key]
          given_name = hash[given_name_key]
          organization_name = hash[organization_name_key]

          [family_name, given_name, organization_name].compact.join(', ')
        end
      end

      def handle_funder(values)
        hashes = JSON.parse(values.first)

        result = []
        hashes.each do |hash|
          funder_name = hash['funder_name']
          funder_awards = hash['funder_award'].join(' | ')
          result << apply_label('Name', funder_name)
          result << apply_label('Awards', funder_awards)
        end

        result
      end

      def handle_alternative_identifier(values)
        hashes = JSON.parse(values.first)

        build_identifier_values(hashes)
      end

      def handle_related_identifier(values)
        hashes = JSON.parse(values.first)

        # Replace "relation_type" with "relation" in hash keys
        hashes.each do |hash|
          hash.transform_keys! { |key| key == "relation_type" ? "relation" : key }
        end

        build_identifier_values(hashes)
      end

      def handle_resource_type(values)
        values.map { |value| Qa::Authorities::Local.subauthority_for('resource_types').find(value).fetch('term') }
      end

      def apply_label(label, value)
        "<strong>#{label}:</strong> #{value}"
      end

      def build_identifier_values(hashes)
        result = []
        hashes.each do |hash|
          hash.each do |key, value|
            label = key.split('_').last
            result << apply_label(label, value)
          end
        end

        result
      end
  end
end

IiifPrint::Metadata.prepend(IiifPrint::MetadataDecorator)
