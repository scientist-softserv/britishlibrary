# Generated via
#  `rails generate hyrax:work ThesisOrDissertation`
module Hyrax
  class ThesisOrDissertationPresenter < ::Hyku::WorkShowPresenter
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIPresenterBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
  end
end
