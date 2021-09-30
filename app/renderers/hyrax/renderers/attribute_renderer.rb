# OVERRIDE FILE from Hyrax v2.9.5
#
# Override this class using #class_eval to avoid needing to copy the entire file over from
# the dependency. For more info, see the "Overrides using #class_eval" section in the README.
#
# Additional OVERRIDE on this file to change the html markup so that each metadata item is wrapped by a div, and they use <dt> and <dd> tags instead of table tags. This prevents the html tags from getting ripped out my the html_safe markup method at the end, and makes it easier to style the metadata.

require_dependency Hyrax::Engine.root.join('app', 'renderers', 'hyrax', 'renderers', 'attribute_renderer').to_s
Hyrax::Renderers::AttributeRenderer.class_eval do
  def render
    values&.delete("")
    markup = ''

    return markup if values.blank? && !options[:include_empty]
    markup << %(<div class='metadata-group'><dt>#{label}</dt>\n<dd><ul class='tabular'>)
    attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")
    Array(values).each do |value|
      markup << "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value.to_s)}</li>"
    end
    markup << %(
        <li>
          <a class="collapse-fields" data-toggle="collapse" href=".collapse" aria-expanded="false" aria-controls="collapse">
            <span>Show More</span>
            <span style='display:none'>Show Less</span>
          </a>
        </li>
        </ul>
      </dd>
    </div>)
    markup.html_safe
  end

  def render_dl_row
    values&.delete("")
    return '' if values.blank? && !options[:include_empty]

    markup = %(<div class='metadata-group'><dt>#{label}</dt>\n<dd><ul class='tabular'>)

    attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")

    markup += Array(values).map do |value|
      "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value.to_s)}</li>"
    end.join
    markup += %(</ul></dd></div>)

    markup.html_safe
  end

end
