# Generated via
#  `rails generate hyrax:work ExhibitionItem`
module Hyrax
  class ExhibitionItemForm < Hyrax::Forms::WorkForm
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIFormBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    include Ubiquity::EditorMetadataFormBehaviour
    include Ubiquity::VersionMetadataFormBehaviour

    self.model_class = ::ExhibitionItem
    self.terms += %i[title alt_title resource_type creator contributor rendering_ids abstract date_published media
                     institution org_unit project_name funder fndr_project_ref event_title event_location event_date
                     series_name editor version_number pagination
                     publisher place_of_publication isbn issn eissn date_accepted date_submitted official_link
                     related_url related_exhibition related_exhibition_venue related_exhibition_date language license rights_statement
                     rights_holder original_doi draft_doi alternate_identifier related_identifier refereed keyword dewey
                     library_of_congress_classification add_info rendering_ids
                    ]
  end
end
