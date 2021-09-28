# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Book do
  subject(:book) { described_class.new }

  it 'has a title' do
    book.title = ['Book Title']
    expect(book.title).to eq ['Book Title']
  end

  it 'has a DOI' do
    book.doi = ['1234']
    expect(book.doi).to eq ['1234']
  end

  it 'has a doi_status_when_public' do
    book.doi_status_when_public = 'draft'
    expect(book.doi_status_when_public).to eq 'draft'
  end
end
