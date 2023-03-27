# frozen_string_literal: true

RSpec.describe Ubiquity::ParseDate do
  describe '.return_date_part' do
    it 'handles YYYY-MM-DD format' do
      date = '2023-12-13'
      expect(described_class.return_date_part(date, 'year')).to eq('2023')
      expect(described_class.return_date_part(date, 'month')).to eq('12')
      expect(described_class.return_date_part(date, 'day')).to eq('13')
    end

    it 'handles MM/DD/YYYY format' do
      date = '12/13/2023'
      expect(described_class.return_date_part(date, 'year')).to eq('2023')
      expect(described_class.return_date_part(date, 'month')).to eq('12')
      expect(described_class.return_date_part(date, 'day')).to eq('13')
    end

    it 'handles YYYY format' do
      date = '2023'
      expect(described_class.return_date_part(date, 'year')).to eq('2023')
      expect(described_class.return_date_part(date, 'month')).to be_nil
      expect(described_class.return_date_part(date, 'day')).to be_nil
    end

    it 'handles full month names' do
      date = 'December 13, 2023'
      expect(described_class.return_date_part(date, 'year')).to eq('2023')
      expect(described_class.return_date_part(date, 'month')).to eq('12')
      expect(described_class.return_date_part(date, 'day')).to eq('13')
    end

    it 'returns nil for invalid dates' do
      date = 'invalid_date'
      expect(described_class.return_date_part(date, 'year')).to be_nil
      expect(described_class.return_date_part(date, 'month')).to be_nil
      expect(described_class.return_date_part(date, 'day')).to be_nil
    end
  end
end
