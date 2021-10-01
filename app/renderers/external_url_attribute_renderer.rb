class ExternalUrlAttributeRenderer < Hyrax::Renderers::AttributeRenderer

  def render
    markup = ''
    values.delete("") if values # delete an empty string in array or it would display
    return markup if values.blank? && !options[:include_empty]
    arr_of_li_values(values) if values.is_a?(Array)
  end

  private

    def arr_of_li_values(value)
      markup = %(<div class='metadata-group'>
                  <dt>#{label}</dt>\n
                  <dd>
                    <ul class='tabular'>)
      sorted_arr = value.sort_by(&:downcase)
      links = sorted_arr.map.with_index do |url, index|
        attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field} #{'collapse' if index > 4}")
        complete_url = "https://" + url
        if label == 'DOI'
          final_url = auto_link(complete_url, html: { target: '_blank' })
        else
          final_url = link_to(url, complete_url)
        end
        markup << "<li#{html_attributes(attributes)}>#{final_url}</li>"
      end
      if sorted_arr.length > 5
        markup << %(
                  <li>
                    <a id="#{field}-collapse" class="collapse-fields" data-toggle="collapse" href=".attribute-#{field}.collapse" aria-expanded="false" aria-controls="collapse">
                      <span>Show More</span>
                      <span style='display:none'>Show Less</span>
                    </a>
                  </li>)
      end
      markup << %(</ul>
              </dd>
            </div>)
      markup.html_safe
    end

end
