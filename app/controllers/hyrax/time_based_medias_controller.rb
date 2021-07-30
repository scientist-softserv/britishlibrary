# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work TimeBasedMedia`

module Hyrax
  class TimeBasedMediasController < SharedBehaviorsController
    self.curation_concern_type = ::TimeBasedMedia

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::TimeBasedMediaPresenter
  end
end
