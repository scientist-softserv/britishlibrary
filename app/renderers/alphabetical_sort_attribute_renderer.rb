class AlphabeticalSortAttributeRenderer < Hyrax::Renderers::AttributeRenderer

  def render
    markup = ''

    return markup if values.blank? && !options[:include_empty]
    markup << %(<div class='metadata-group'><dt>#{label}</dt>\n<dd><ul class='tabular'>)
    sorted_arr = Array(values).sort_by(&:downcase)
    sorted_arr.each_with_index do |value, index|
      attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field} #{'collapse' if index > 4}")
      markup << "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value.to_s)}</li>"
    end
    markup << %(<li><button id="#{field}-collapse" class="collapse-fields" data-toggle="collapse" data-target=".attribute-#{field}.collapse" aria-expanded="false" aria-controls="collapse"><span>Show more</span><span style='display:none'>Close list</span></button></li>) if Array(values).length > 5
    markup << %(</ul></dd></div>)
    markup.html_safe
  end
end