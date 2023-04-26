# Generated via
#  `rails generate hyrax:work Page`
module Hyrax
  # Generated form for Page
  class PageForm < Hyrax::Forms::WorkForm
    self.model_class = ::Page
    self.terms += [:resource_type]
  end
end
