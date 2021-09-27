# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ThesisOrDissertation do
  subject(:thesis_or_dissertation) { described_class.new }

  it 'has a title' do
    thesis_or_dissertation.title = ['Title']
    expect(thesis_or_dissertation.title).to eq ['Title']
  end

  it 'has a DOI' do
    thesis_or_dissertation.doi = ['1234']
    expect(thesis_or_dissertation.doi).to eq ['1234']
  end

  it 'has a doi_status_when_public' do
    thesis_or_dissertation.doi_status_when_public = 'draft'
    expect(thesis_or_dissertation.doi_status_when_public).to eq 'draft'
  end
end
