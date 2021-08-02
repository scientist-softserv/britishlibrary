# frozen_string_literal: true

# We create a custom renderer because the `pagination` attribute is otherwise passed and inherits from existing CSS class

class PageAttributeRenderer < Hyrax::Renderers::AttributeRenderer
  def render
    markup = ''
    values&.delete("") # delete an empty string in array or it would display the field on works show page
    return markup if values.blank? && !options[:include_empty]
    markup << %(<div class='metadata-group'><dt>#{label}</dt>\n
                <dd><ul class='tabular'><li class='attribute page'>#{values.join}</li>
                </ul></dd></div>)
    markup.html_safe
  end
end
