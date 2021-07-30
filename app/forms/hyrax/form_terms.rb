# frozen_string_literal: true

module Hyrax
  module FormTerms
    include Hyrax::Forms
    # overrides Hyrax::Forms::WorkForm
    # to display 'license' in the 'base-terms' div on the user dashboard "Add New Work" description
    # by getting iterated over in hyrax/app/views/hyrax/base/_form_metadata.html.erb
    def primary_terms
      super + %i[license]
    end

    # TODO: do we need rendering_ids?
    def secondary_terms
      super - %i[rendering_ids date_created identifier collection_id collection_names]
    end
    # added by ubiquity press to store doi options
    attr_accessor :doi_options
  end
end
