# frozen_string_literal: true

RSpec.describe FeaturedCollectionList, type: :model do
  let(:collection1) { build(:collection) }
  let(:collection2) { build(:collection) }

  describe 'featured_collections' do
    before do
      create(:featured_collection, collection_id: collection1.id)
      create(:featured_collection, collection_id: collection2.id)
    end

    it 'is a list of the featured collection objects, each with the collection\'s solr_doc' do
      presenter_ids = subject.featured_collections.map { |fw| fw.presenter.id }
      expect(presenter_ids).to contain_exactly(collection1.id, collection2.id)
      subject.featured_collections.each do |fw|
        expect(fw.presenter).to be_kind_of Hyrax::WorkShowPresenter
      end
    end

    context 'when one of the files is deleted' do
      before do
        collection1.destroy
      end

      it 'is a list of the remaining featured collection objects, each with the collection\'s solr_doc' do
        expect(subject.featured_collections.size).to eq 1
        presenter = subject.featured_collections.first.presenter
        expect(presenter).to be_kind_of Hyrax::WorkShowPresenter
        expect(presenter.id).to eq collection2.id
      end
    end
  end

  describe '#featured_collections_attributes=' do
    # We don't need to persist the given collection. This saves a few LDP calls.
    let(:collection_id) { 'no-need-to-persist' }
    let(:featured_collection) { create(:featured_collection, collection_id: collection_id) }

    let(:attributes) do
      ActionController::Parameters.new(
        "0" => {
          "id" => featured_collection.id,
          "order" => "6"
        }
      ).permit!
    end
    let(:instance) { described_class.new }

    subject { instance.featured_collections_attributes = attributes }

    it "sets order" do
      subject
      expect(featured_collection.order).to eq 6
    end
  end

  it { is_expected.to delegate_method(:empty?).to(:featured_collections) }
end