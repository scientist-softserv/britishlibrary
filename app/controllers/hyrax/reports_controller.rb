# Generated via
#  `rails generate hyrax:work Report`

module Hyrax
  class ReportsController < SharedBehaviorsController
    self.curation_concern_type = ::Report

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ReportPresenter
  end
end
