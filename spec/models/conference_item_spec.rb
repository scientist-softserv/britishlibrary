# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConferenceItem do
  subject(:conference_item) { described_class.new }

  it 'has a title' do
    conference_item.title = ['Title']
    expect(conference_item.title).to eq ['Title']
  end

  it 'has a DOI' do
    conference_item.doi = ['1234']
    expect(conference_item.doi).to eq ['1234']
  end

  it 'has a doi_status_when_public' do
    conference_item.doi_status_when_public = 'draft'
    expect(conference_item.doi_status_when_public).to eq 'draft'
  end
end
