module Hyrax
  class ArticleForm < Hyrax::Forms::WorkForm
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIFormBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    self.model_class = ::Article

    self.terms += %i[title alt_title resource_type creator contributor abstract date_published institution org_unit
                     project_name funder fndr_project_ref journal_title alternative_journal_title volume issue
                     pagination article_num publisher place_of_publication issn eissn date_accepted date_submitted
                     official_link related_url language license rights_statement rights_holder original_doi draft_doi
                     alternate_identifier related_identifier refereed keyword dewey library_of_congress_classification
                     add_info rendering_ids
                    ]

    self.required_fields += %i[journal_title]
  end
end
