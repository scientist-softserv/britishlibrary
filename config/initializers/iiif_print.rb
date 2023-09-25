IiifPrint.config do |config|
  # NOTE: WorkTypes and models are used synonymously here.
  # Add models to be excluded from search so the user
  # would not see them in the search results.
  # by default, use the human readable versions like:
  # @example
  #   # config.excluded_model_name_solr_field_values = ['Generic Work', 'Image']
  #
  # config.excluded_model_name_solr_field_values = ['Pdf Page']

  # Add configurable solr field key for searching,
  # default key is: 'human_readable_type_sim'
  # if another key is used, make sure to adjust the
  # config.excluded_model_name_solr_field_values to match
  # @example
  # config.excluded_model_name_solr_field_key = 'human_readable_type_tesim'

  config.default_iiif_manifest_version = 3

  # @note These fields will appear in rendering order.
  config.metadata_fields = {
    alt_title: {},
    resource_type: {},
    creator: { render_as: :faceted },
    contributor: {},
    date_published: {},
    institution: {},
    org_unit: {},
    project_name: {},
    funder: {},
    series_name: {},
    book_title: {},
    editor: {},
    volume: {},
    edition: {},
    pagination: {},
    publisher: { render_as: :faceted },
    place_of_publication: {},
    isbn: {},
    issn: {},
    eissn: {},
    date_accepted: {},
    official_link: {},
    related_url: {},
    license: { render_as: :license },
    rights_statement: { render_as: :rights_statement },
    rights_holder: {},
    original_doi: {},
    alternate_identifier: {},
    related_identifier: {},
    keyword: { render_as: :faceted },
    dewey: {},
    library_of_congress_classification: { render_as: :faceted },
    add_info: {},
    collection: {}
  }
end

# Override Hrax::WorkShowPresenter.authorized_item_ids to disallow "Pdf Page" work type from showing as members
Hyrax::WorkShowPresenter.class_eval do
  private
    # list of item ids to display is based on ordered_ids
    def authorized_item_ids
      @member_item_list_ids ||= begin
        items = ordered_ids
        items.delete_if { |m| !current_ability.can?(:read, m) } if Flipflop.hide_private_items?
        #TODO a better way to detect if the user is signed in... if only there was a user_signed_in?
        items.delete_if { |m| ActiveFedora::Base.where(id: m).first.human_readable_type == "Pdf Page" && current_ability.current_user.email.blank? }
        items
      end
    end
end

