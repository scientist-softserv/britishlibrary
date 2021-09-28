# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dataset do
  subject(:dataset) { described_class.new }

  it 'has a title' do
    dataset.title = ['Dataset Title']
    expect(dataset.title).to eq ['Dataset Title']
  end

  it 'has a DOI' do
    dataset.doi = ['1234']
    expect(dataset.doi).to eq ['1234']
  end

  it 'has a doi_status_when_public' do
    dataset.doi_status_when_public = 'draft'
    expect(dataset.doi_status_when_public).to eq 'draft'
  end
end
