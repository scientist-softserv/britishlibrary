# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExhibitionItem do
  subject(:exhibition_item) { described_class.new }

  it 'has a title' do
    exhibition_item.title = ['Title']
    expect(exhibition_item.title).to eq ['Title']
  end

  it 'has a DOI' do
    exhibition_item.doi = ['1234']
    expect(exhibition_item.doi).to eq ['1234']
  end

  it 'has a doi_status_when_public' do
    exhibition_item.doi_status_when_public = 'draft'
    expect(exhibition_item.doi_status_when_public).to eq 'draft'
  end
end
