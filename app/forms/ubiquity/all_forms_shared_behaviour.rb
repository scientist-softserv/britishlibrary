module Ubiquity
  module AllFormsSharedBehaviour
    extend ActiveSupport::Concern

    # TODO this has multi-tenant search stuff include(::Ubiquity::HyraxWorkFormOverride)


    included do
      attr_accessor :contributor_group, :contributor_name_type, :contributor_type, :contributor_given_name,
                    :contributor_family_name, :contributor_orcid, :contributor_isni, :contributor_ror, :contributor_grid,
                    :contributor_wikidata, :contributor_position, :contributor_organization_name,
                    :contributor_institutional_relationship

      attr_accessor :creator_group, :creator_name_type, :creator_organization_name, :creator_given_name,
                    :creator_family_name, :creator_orcid, :creator_isni, :creator_ror, :creator_grid,
                    :creator_wikidata, :creator_position, :creator_institutional_relationship

      attr_accessor :funder_group, :funder_name, :funder_doi, :funder_award, :funder_position,
                    :funder_isni, :funder_ror

      attr_accessor :alternate_identifier_group, :related_identifier_group,
                    :date_published_group, :date_accepted_group, :date_submitted_group,
                    :event_date, :related_exhibition_date

      attr_accessor :current_he_institution_group, :current_he_institution_name,
                    :current_he_institution_isni, :current_he_institution_ror

      attr_accessor :note, :account, :doi_options

      # terms inherited from Hyrax::Forms::WorkForm are removed
      # to then be added at the desired position in each work type form (ex `article_form`)
      self.terms -= %i[title
                       creator
                       contributor
                       description
                       keyword
                       license
                       rights_statement
                       publisher
                       date_created
                       subject
                       language
                       identifier
                       based_near
                       related_url
                       source]
      # default required_fields: [:title, :creator, :keyword, :rights_statement]
      # removing fields that are not required across all types or that we want displayed in a different order
      # creator is listed here so it groups with the other required fields in the UI, the validations for it however
      # are handled in creator.js
      self.required_fields -= %i[creator keyword rights_statement]
      self.required_fields += %i[resource_type institution creator]
    end

    class_methods do

      # rubocop:disable Metrics/MethodLength
      def build_permitted_params
        super.tap do |permitted_params|
          permitted_params << {contributor_group: [:contributor_organization_name, :contributor_given_name,
            :contributor_family_name, :contributor_name_type, :contributor_orcid, :contributor_isni, :contributor_ror, :contributor_grid,
            :contributor_wikidata, :contributor_position, :contributor_type, :contributor_institutional_relationship => []
          ]}

          permitted_params << {creator_group: [:creator_organization_name, :creator_given_name,
            :creator_family_name, :creator_name_type, :creator_orcid, :creator_isni, :creator_ror, :creator_grid,
            :creator_wikidata, :creator_position, :creator_institutional_relationship => []
          ]}

          permitted_params << {funder_group: [:funder_name, :funder_doi, :funder_position,
            :funder_isni, :funder_ror, :funder_award => []
          ]}

          permitted_params << { alternate_identifier_group: %i[alternate_identifier alternate_identifier_type] }

          permitted_params << { related_identifier_group: %i[related_identifier related_identifier_type relation_type] }

          permitted_params << { date_published_group: %i[date_published_year date_published_month date_published_day] }
          permitted_params << { date_accepted_group: %i[date_accepted_year date_accepted_month date_accepted_day] }
          permitted_params << { date_submitted_group: %i[date_submitted_year date_submitted_month date_submitted_day] }
          permitted_params << { event_date_group: %i[event_date_year event_date_month event_date_day] }
          permitted_params << { related_exhibition_date_group: %i[related_exhibition_date_year
                                                                  related_exhibition_date_month
                                                                  related_exhibition_date_day] }
          permitted_params << { current_he_institution_group: %i[current_he_institution_name
                                                                 current_he_institution_isni
                                                                 current_he_institution_ror] }

          permitted_params << :doi_options

          permitted_params << :record_level_file_version_declaration
        end
      end
    end # closes class class_methods
    # rubocop:enable Metrics/MethodLength

    # instance methods
    def title
      super.first || ""
    end
  end
end
