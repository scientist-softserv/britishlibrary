# frozen_string_literal: true

RSpec.describe OpenAccessService do
  subject { described_class.new(work: work).unrestricted_use_files? }

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
  # rubocop:disable Metrics/LineLength
  # funder is an ugly thing as stored! Here we have 2 funders
  let(:funder) do
    ["[{\"funder_name\":\"Biotechnology and Biological Sciences Research Council\",\"funder_doi\":\"http://dx.doi.org/10.13039/501100000268\",\"funder_position\":\"0\",\"funder_isni\":\"0000 0001 2189 3037\",\"funder_ror\":\"https://ror.org/00cwqg982\"},{\"funder_name\":\"British Academy\",\"funder_doi\":\"http://dx.doi.org/10.13039/501100000286\",\"funder_position\":\"1\",\"funder_isni\":\"0000 0004 0411 8698\",\"funder_ror\":\"https://ror.org/0302b4677\"}]"]
  end
  let(:plan_s_funder) { PlanSFunder.new(funder_doi: 'http://dx.doi.org/10.13039/501100000268', funder_name: 'Biotechnology and Biological Sciences Research Council', funder_status: 'active' ) }

  # rubocop:enable Metrics/LineLength

  describe '#unrestricted_use_files?' do
    context 'for scholarly articles' do
      let(:work) { generic_work }

      context 'when unrestricted use it is true' do
        before do
          allow(work).to receive(:file_sets).and_return([filesets])
          allow(filesets).to receive(:open_access?).and_return(true)
          allow(PlanSFunder).to receive(:where).and_return([plan_s_funder])
        end

        it { is_expected.to be_truthy }
      end

      context 'when not Plan S funder it is falsey' do
        before do
          allow(work).to receive(:file_sets).and_return([filesets])
          allow(filesets).to receive(:open_access?).and_return(true)
          allow(PlanSFunder).to receive(:where).and_return([])
        end

        it { is_expected.to be_falsey }
      end
    end

    context 'for books' do
      let(:work) { book }

      context 'when unrestricted use' do
        before do
          allow(work).to receive(:file_sets).and_return([filesets])
          allow(filesets).to receive(:open_access?).and_return(true)
          allow_any_instance_of(described_class).to receive(:coalition_s?).and_return(true)
        end

        it 'returns true' do
          expect(subject).to be_truthy
        end
      end

      context 'when under embargo < 12 months' do
        before do
          allow(work).to receive(:file_sets).and_return([filesets])
          allow(filesets).to receive(:open_access?).and_return(true)
          allow_any_instance_of(described_class).to receive(:embargo_within_max_allowed_age?).and_return(true)
          allow_any_instance_of(described_class).to receive(:coalition_s?).and_return(true)
        end

        it 'returns true' do
          expect(subject).to be_truthy
        end
      end

      context 'when under embargo > 12 months' do
        before do
          allow(work).to receive(:file_sets).and_return([filesets])
          allow(filesets).to receive(:open_access?).and_return(true)
          allow_any_instance_of(described_class).to receive(:embargo_within_max_allowed_age?).and_return(false)
          allow_any_instance_of(described_class).to receive(:coalition_s?).and_return(true)
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
        described_class.new(work: work).send(:embargo_within_max_allowed_age?,
                                             max_embargo_mths: 5)
      end

      let(:release) { Date.new(2023, 3, 30) }

      it { is_expected.to be_falsey }
    end

    describe 'when max months is zero' do
      subject do
        described_class.new(work: work).send(:embargo_within_max_allowed_age?,
                                             max_embargo_mths: 0)
      end

      let(:release) { nil }

      it { is_expected.to be_falsey }
    end

    describe 'when embargo longer than max months' do
      subject do
        described_class.new(work: work).send(:embargo_within_max_allowed_age?,
                                             max_embargo_mths: 1)
      end

      let(:release) { nil }

      it { is_expected.to be_falsey }
    end

    describe 'when embargo shorter than max months' do
      subject do
        described_class.new(work: work).send(:embargo_within_max_allowed_age?,
                                             max_embargo_mths: 12)
      end

      let(:release) { nil }

      it { is_expected.to be_truthy }
    end
  end
end
