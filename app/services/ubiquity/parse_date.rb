module Ubiquity
  class ParseDate
    attr_reader :data, :date_field

    def initialize(date_data, date_field_name)
      @date_field = date_field_name
      @data = date_data.split('||')
    end

    def process_dates
      return_values = []
      @data.map do |date|
        return_values << transform_date_group(date)
      end
      return_values
    end

    def self.return_date_part(date, date_part)
      return nil if date.blank?
      return date if date_part == 'year' && date.match(/^\d{4}$/)

      parsed_date = parse_date_by_format(date)

      return nil if parsed_date.nil?

      extract_date_part(parsed_date, date, date_part)
    end

    def self.transform_published_date_group(date_published_hash)
      if date_published_hash.present?
        date = ''
        date_published_hash.each do |date_hash|
          date << date_hash[:date_published_year] if date_hash[:date_published_year].present?
          date << '-' + date_hash[:date_published_month] if date_hash[:date_published_month].present?
          if date_hash[:date_published_day].present? && date_hash[:date_published_month].present?
            date << '-' + date_hash[:date_published_day]
          end
        end
        date
      end
    end

    private

    def self.parse_date_by_format(date)
      case date
      when /^\d{4}-\d{2}$/ then Date.strptime(date, '%Y-%m') # 'YYYY-MM' format
      when /^\d{1,2}\/\d{4}$/ then Date.strptime(date, '%m/%Y') # 'MM/YYYY' format
      when %r{\d{1,2}/\d{1,2}/\d{4}} then Date.strptime(date, '%m/%d/%Y') # 'MM/DD/YYYY' format
      else
        Date.parse(date) rescue nil
      end
    end

    def self.extract_date_part(parsed_date, original_date, date_part)
      case date_part
      when 'year'  then parsed_date.strftime("%Y")
      when 'month' then parsed_date.strftime("%m")
      when 'day'   then day_part(parsed_date, original_date)
      end
    end

    def self.day_part(parsed_date, original_date)
      if parsed_date.day == 1 && (original_date.match(/^\d{4}-\d{2}$/) || original_date.match(/^\d{1,2}\/\d{4}$/))
        nil
      else
        parsed_date.strftime("%d")
      end
    end

    def transform_date_group(date)
      date_parts =  date.split('-')
      year = "#{date_field}_year"
      month = "#{date_field}_month"
      day = "#{date_field}_day"
      if date_parts.count == 2
        #returns a hash in the form {"date_published_year"=>"2017", "date_published_month"=>"02"}
        Hash[[ [year,  date_parts.first], [month,  date_parts.last] ]]
      elsif date_parts.count > 2
        #returns a hash in the form {"date_published_year"=>"2017", "date_published_month"=>"02", "date_published_day"=>"02"}
        Hash[[ [year,  date_parts.first], [month,  date_parts[1]], [day,  date_parts.last]  ]]
      else
        Hash[[ [year,  date_parts.first] ]]
      end
    end
  end
end
