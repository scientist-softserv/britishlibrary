# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimeBasedMedia do
  subject(:time_based_media) { described_class.new }

  it 'has a title' do
    time_based_media.title = ['Title']
    expect(time_based_media.title).to eq ['Title']
  end

  it 'has a DOI' do
    time_based_media.doi = ['1234']
    expect(time_based_media.doi).to eq ['1234']
  end

  it 'has a doi_status_when_public' do
    time_based_media.doi_status_when_public = 'draft'
    expect(time_based_media.doi_status_when_public).to eq 'draft'
  end
end
