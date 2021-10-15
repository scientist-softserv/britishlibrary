# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  class ImageForm < Hyrax::Forms::WorkForm
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIFormBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour

    self.model_class = ::Image
    self.terms += %i[title alt_title resource_type creator contributor abstract date_published media duration institution
                     org_unit project_name funder fndr_project_ref publisher place_of_publication date_accepted
                     date_submitted official_link related_url related_exhibition related_exhibition_venue related_exhibition_date language
                     license rights_statement rights_holder original_doi draft_doi alternate_identifier related_identifier
                     rendering_ids keyword dewey library_of_congress_classification add_info
                    ]
  end
end
