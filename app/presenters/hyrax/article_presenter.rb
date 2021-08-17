module Hyrax
  class ArticlePresenter < ::Hyku::WorkShowPresenter
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIPresenterBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
    # Override to inject work_type for proper i18n lookup
    def attribute_to_html(field, options = {})
      options[:html_dl] = true
      options[:work_type] = 'article'
      super
    end
  end
end
