# Generated via
#  `rails generate hyrax:work Report`
module Hyrax
  class ReportForm < Hyrax::Forms::WorkForm
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIFormBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    include Ubiquity::EditorMetadataFormBehaviour

    self.model_class = ::Report
    self.terms += %i[title  alt_title resource_type creator contributor abstract date_published institution org_unit project_name
                     funder fndr_project_ref series_name editor volume edition pagination publisher place_of_publication
                     isbn issn eissn date_accepted date_submitted official_link related_url language license
                     rights_statement rights_holder original_doi draft_doi alternate_identifier related_identifier
                     refereed keyword dewey library_of_congress_classification add_info rendering_ids
                    ]
  end
end
