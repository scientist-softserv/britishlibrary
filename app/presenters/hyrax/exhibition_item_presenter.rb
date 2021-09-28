# Generated via
#  `rails generate hyrax:work ExhibitionItem`
module Hyrax
  class ExhibitionItemPresenter < ::Hyku::WorkShowPresenter
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIPresenterBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
  end
end
