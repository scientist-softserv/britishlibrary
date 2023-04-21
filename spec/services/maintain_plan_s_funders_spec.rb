# frozen_string_literal: true

RSpec.describe MaintainPlanSFunders do
  let(:original_csv_path) { 'spec/lib/data/plan_s_funders.csv' }
  let(:updated_csv_path) { 'spec/lib/data/plan_s_funders_updated.csv' }
  let(:original_array) { ["http://dx.doi.org/10.13039/100005393", "https://doi.org/10.13039/501100002341", "http://dx.doi.org/10.13039/501100011858"] }
  let(:updated_array) { ["http://dx.doi.org/10.13039/100005393", "https://doi.org/10.13039/501100002341"] }

  describe '#call' do
    before do
      PlanSFunder.destroy_all
    end

    it 'loads PlanSFunder data' do
      output = described_class.call(csv_path: original_csv_path)
      expect(PlanSFunder.count).to eq 3
      expect(output).to eq(original_array)
    end

    it 'updates PlanSFunder data' do
      output = described_class.call(csv_path: updated_csv_path)
      expect(PlanSFunder.count).to eq 2
      expect(PlanSFunder.where(funder_doi: "https://doi.org/10.13039/501100002341").first.funder_status).to eq('inactive')
      expect(output).to eq(updated_array)
    end
  end
end
