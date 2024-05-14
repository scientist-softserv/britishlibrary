# Override IiifPrint::Configuration to allow a config item to limit splitting PDFs by page count (IiifPrint 1.0.0 8fdf56e)
IiifPrint::Configuration.class_eval do
  attr_writer :split_pdf_page_limit
  # rubocop:disable Metrics/MethodLength
  # @api private
  # @note These fields will appear in rendering order.
  # @todo To move this to an `@api public` state, we need to consider what a proper configuration looks like.
  def split_pdf_page_limit
    @split_pdf_page_limit ||= 100
  end
end

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

  config.split_pdf_page_limit = 100

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

# Override IiifPrint::SplitPdfs::ChildWorkCreationFromPdfService (IiifPrint 1.0.0 8fdf56e)
# IiiifPrint rendering does not do well when there are many pages
# So enforce a page limit over which IiifPRint will not split a PDF
# into childworks with images for each page
# Duplicate pagecount from IiifPrint::SplitPdfs::BaseSplitter
IiifPrint::SplitPdfs::ChildWorkCreationFromPdfService.class_eval do

  PAGE_COUNT_REGEXP = %r{^Pages: +(\d+)$}.freeze

  def self.pagecount(pdfpath)
    # Default to a value that will avoid
    # IiifPrint splitting from happening
    pagecount=IiifPrint.config.split_pdf_page_limit+1
    cmd = "pdfinfo #{pdfpath}"
    Open3.popen3(cmd) do |_stdin, stdout, _stderr, _wait_thr|
      match = PAGE_COUNT_REGEXP.match(stdout.read)
      pagecount = match[1].to_i
    end
    pagecount
  end

  def self.pdfs_only_for(paths)
    paths.select { |path| path.end_with?('.pdf', '.PDF') && pagecount(path) < IiifPrint.config.split_pdf_page_limit }
  end
end

