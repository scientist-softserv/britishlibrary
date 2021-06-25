class AlphabeticalSortAttributeRenderer < Hyrax::Renderers::AttributeRenderer

  def render
    markup = ''

    return markup if values.blank? && !options[:include_empty]
    markup << %(<div class='metadata-group'><dt>#{label}</dt>\n<dd><ul class='tabular'>)
    attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")
    sorted_arr = Array(values).sort_by(&:downcase)
    sorted_arr.each do |value|
      markup << "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value.to_s)}</li>"
    end
    markup << %(</ul></dd></div>)
    markup.html_safe
  end
end