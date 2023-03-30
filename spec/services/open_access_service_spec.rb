# frozen_string_literal: true

RSpec.describe OpenAccessService do
  subject { described_class.unrestricted_use_files_for?(work: work) }

  let(:book) { build(:book_with_one_file, funder: funder) }
  let(:generic_work) do
    build(:work_with_one_file,
          refereed: 'Peer-reviewed',
          record_level_file_version_declaration: '1',
          funder: funder)
  end
  let(:image) { build(:image) }
  let(:filesets) { double }
  let(:embargo) { double }
  let(:funder) { [] }

  describe '#unrestricted_use_files_for?' do
    context 'for scholarly articles' do
      let(:work) { generic_work }

      context 'when unrestricted use' do
        before do
          allow(work).to receive(:file_sets).and_return([filesets])
          allow(filesets).to receive(:open_access?).and_return(true)
        end
        it 'returns true' do
          expect(subject).to be_truthy
        end
      end
    end

    context 'for books' do
      let(:work) { book }

      context 'when unrestricted use' do
        before do
          allow(work).to receive(:file_sets).and_return([filesets])
          allow(filesets).to receive(:open_access?).and_return(true)
        end

        it 'returns true' do
          expect(subject).to be_truthy
        end
      end

      context 'when under embargo < 12 months' do
        before do
          allow(work).to receive(:file_sets).and_return([filesets])
          allow(filesets).to receive(:open_access?).and_return(true)
          allow(described_class).to receive(:embargo_within_max_allowed_age?).and_return(true)
        end

        it 'returns true' do
          expect(subject).to be_truthy
        end
      end

      context 'when under embargo > 12 months' do
        before do
          allow(work).to receive(:file_sets).and_return([filesets])
          allow(filesets).to receive(:open_access?).and_return(true)
          allow(described_class).to receive(:embargo_within_max_allowed_age?).and_return(false)
        end

        it 'returns false' do
          expect(subject).to be_falsey
        end
      end
    end

    context 'for other work types' do
      let(:work) { image }

      it 'returns false unless in listed classes' do
        expect(subject).to be_falsey
      end
    end
  end

  describe '#coalition_s_funder?' do
    subject { described_class.send(:coalition_s_funder?, work: work) }

    let(:work) { generic_work }

    it { is_expected.to be_truthy }
  end

  describe '#embargo_within_max_allowed_age?' do
    let(:work) { generic_work }
    let(:embargo) do
      double(embargo_release_date: release,
             embargo_history: history_msg,
             create_date: created)
    end
    let(:created) { Date.new(2023, 1, 1) }
    let(:history_msg) { ['An active embargo was deactivated on 2023-03-27. Its release date was 2023-03-28T00:00:00+00:00. Visibility during embargo was restricted and intended visibility after embargo was open'] }

    before do
      allow(work).to receive(:embargo_id).and_return('12345')
      allow(work).to receive(:embargo).and_return(embargo)
    end

    describe 'when there is an embargo date' do
      subject do
        described_class.send(:embargo_within_max_allowed_age?,
                             work: work,
                             max_embargo_mths: 5)
      end

      let(:release) { Date.new(2023, 3, 30) }

      it { is_expected.to be_falsey }
    end

    describe 'when max months is zero' do
      subject do
        described_class.send(:embargo_within_max_allowed_age?,
                             work: work,
                             max_embargo_mths: 0)
      end

      let(:release) { nil }

      it { is_expected.to be_falsey }
    end

    describe 'when embargo longer than max months' do
      subject do
        described_class.send(:embargo_within_max_allowed_age?,
                             work: work,
                             max_embargo_mths: 1)
      end

      let(:release) { nil }

      it { is_expected.to be_falsey }
    end

    describe 'when embargo shorter than max months' do
      subject do
        described_class.send(:embargo_within_max_allowed_age?,
                             work: work,
                             max_embargo_mths: 12)
      end

      let(:release) { nil }

      it { is_expected.to be_truthy }
    end
  end
end
