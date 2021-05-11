# Generated via
#  `rails generate hyrax:work ExhibitionItem`

module Hyrax
  class ExhibitionItemsController < SharedBehaviorsController
    self.curation_concern_type = ::ExhibitionItem

    # Use this line if you want to use a custom presenter
    #self.show_presenter = Hyrax::ExhibitionItemPresenter
  end
end
