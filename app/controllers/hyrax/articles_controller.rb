# frozen_string_literal: true

module Hyrax
  class ArticlesController < SharedBehaviorsController
    self.curation_concern_type = ::Article

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ArticlePresenter
  end
end
