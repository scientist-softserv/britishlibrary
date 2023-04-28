# Generated via
#  `rails generate hyrax:work PdfPage`
module Hyrax
  # Generated controller for PdfPage
  class PdfPagesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::PdfPage

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PdfPagePresenter
  end
end
