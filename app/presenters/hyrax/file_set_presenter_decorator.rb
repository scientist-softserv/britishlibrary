module Hyrax
  module FileSetPresenterDecorator
    delegate :mesh?, to: :solr_document
  end
end

Hyrax::FileSetPresenter.prepend(Hyrax::FileSetPresenterDecorator)
