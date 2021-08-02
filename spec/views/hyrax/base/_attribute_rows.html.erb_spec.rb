# frozen_string_literal: true

RSpec.describe 'hyrax/base/_attribute_rows.html.erb', type: :view do
  let(:url) { 'http://example.com' }
  let(:license) { 'CC BY 4.0 Attribution' }

  # let(:ability) { double }
  # let(:work) do
  #   stub_model(GenericWork,
  #              related_url: [url],
  #              license: [license])
  # end
  # let(:solr_document) do
  #   SolrDocument.new(has_model_ssim: 'GenericWork',
  #                    rights_statement_tesim: [license],
  #                    related_url_tesim: [url])
  # end
  # let(:presenter) { Hyrax::WorkShowPresenter.new(solr_document, ability) }

  # let(:page) do
  #   render 'hyrax/base/attribute_rows', presenter: presenter
  #   Capybara::Node::Simple.new(rendered)
  # end

  # TODO(alishaevn): get this spec to work
  xit 'shows the license attribute' do
    expect(page).to have_text(license)
  end
end
