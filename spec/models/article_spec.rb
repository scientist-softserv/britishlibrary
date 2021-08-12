# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Article do
  subject(:article) { described_class.new }

  it 'has a title' do
    article.title = ['Article Title']
    expect(article.title).to eq ['Article Title']
  end

  it 'has a DOI' do
    article.doi = ['1234']
    expect(article.doi).to eq ['1234']
  end

  it 'has a doi_status_when_public' do
    article.doi_status_when_public = 'draft'
    expect(article.doi_status_when_public).to eq 'draft'
  end
end
