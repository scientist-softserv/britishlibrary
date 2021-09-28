# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Report do
  subject(:report) { described_class.new }

  it 'has a title' do
    report.title = ['Title']
    expect(report.title).to eq ['Title']
  end

  it 'has a DOI' do
    report.doi = ['1234']
    expect(report.doi).to eq ['1234']
  end

  it 'has a doi_status_when_public' do
    report.doi_status_when_public = 'draft'
    expect(report.doi_status_when_public).to eq 'draft'
  end
end
