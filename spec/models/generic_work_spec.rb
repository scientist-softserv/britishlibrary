# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenericWork do
  subject(:generic_work) { described_class.new }

  it 'has a title' do
    generic_work.title = ['Generic Work Title']
    expect(generic_work.title).to eq ['Generic Work Title']
  end

  it 'has a DOI' do
    generic_work.doi = ['1234']
    expect(generic_work.doi).to eq ['1234']
  end

  it 'has a doi_status_when_public' do
    generic_work.doi_status_when_public = 'draft'
    expect(generic_work.doi_status_when_public).to eq 'draft'
  end
end
