class MultipleDatesAttributeRenderer < Hyrax::Renderers::AttributeRenderer

  def render
    markup = ''

    return markup if values.blank? && !options[:include_empty]
    markup << %(
      <div class='metadata-group'>
        <dt>#{label}</dt>\n
        <dd>
          <ul class='tabular'>)
          sorted_arr = Array(values).sort_by(&:downcase)
          sorted_arr.each_with_index do |value, index|
            attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field} #{'collapse' if index > 4}")
      # hide default values added to obtain a valid Date format; see 'all_models_virtual_fields'
      if value[(5..9)] == '01-01'
        value = value[(0..3)]
      elsif value[(8..9)] == '01'
        value = value[(0..6)]
      end
      markup << "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value.to_s)}</li>"
    end
    if Array(values).length > 5
      markup << %(
            <li>
              <a id="#{field}-collapse" class="collapse-fields" data-toggle="collapse" href=".attribute-#{field}.collapse" aria-expanded="false" aria-controls="collapse">
                <span>Show More</span>
                <span style='display:none'>Show Less</span>
              </a>
            </li>)
    end
    markup << %(
        </ul>
      </dd>
    </div>)
    markup.html_safe
  end
end