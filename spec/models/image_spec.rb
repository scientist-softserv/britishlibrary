# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`

RSpec.describe Image do
  describe 'indexer' do
    subject { described_class.indexer }

    it { is_expected.to eq ImageIndexer }
  end

  subject(:image) { described_class.new }

  it 'has a title' do
    image.title = ['Image Title']
    expect(image.title).to eq ['Image Title']
  end

  it 'has a DOI' do
    image.doi = ['1234']
    expect(image.doi).to eq ['1234']
  end

  it 'has a doi_status_when_public' do
    image.doi_status_when_public = 'draft'
    expect(image.doi_status_when_public).to eq 'draft'
  end
end
