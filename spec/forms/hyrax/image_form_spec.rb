# frozen_string_literal: true

# Generated via
# `rails generate hyrax:work Image`

# TODO - expand test to match code. 
# Researched that extent is no longer being user per 
# commit 23125eae0da43dddc3bb040d5166e5d1de807099
RSpec.describe Hyrax::ImageForm do
  let(:work) { Image.new }
  let(:form) { described_class.new(work, nil, nil) }
  let(:file_set) { FactoryBot.create(:file_set) }

  describe ".model_attributes" do
    subject { described_class.model_attributes(params) }

    let(:params) { ActionController::Parameters.new(attributes) }
    let(:attributes) do
      {
        title: ['a', 'b'],
        extent: ['extent']
      }
    end

    it 'permits metadata parameters' do
      expect(subject['title']).to eq ['a', 'b']
    end

    it 'excludes non-permitted parameters' do
      expect(subject).not_to have_key 'extent'
    end
  end

  include_examples("work_form")
end
