# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookContribution do
  subject(:book_contribution) { described_class.new }

  it 'has a title' do
    book_contribution.title = ['Title']
    expect(book_contribution.title).to eq ['Title']
  end

  it 'has a DOI' do
    book_contribution.doi = ['1234']
    expect(book_contribution.doi).to eq ['1234']
  end

  it 'has a doi_status_when_public' do
    book_contribution.doi_status_when_public = 'draft'
    expect(book_contribution.doi_status_when_public).to eq 'draft'
  end
end
