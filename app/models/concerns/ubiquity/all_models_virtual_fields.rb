module Ubiquity
  module AllModelsVirtualFields
    extend ActiveSupport::Concern

    included do

      before_save :save_contributor
      before_save :save_creator

      #These are used in the forms to populate fields that will be stored in json fields
      #The json fields in this case are creator and contributor
      attr_accessor :creator_group, :contributor_group
    end

    private

    #
    # We are addressing 2 use case for each json field
    # 1. When saving a new record
    #    a. loop through the array and reject empty or nil values from the hash.
    #    b. Using the data from 1a above, run an additionally t detect if the hash keys are meant for default values only.
    #    c. If step 1b returns true, then we just clear the array by settin the json field to an empty arry
    #
    # 2 when updating a record that has a mix, that is some hash need to be kept while removing those hash with only default values
    #    a. Same as step 1a and 1b Above
    #    b. Using the array of hash from the above step remove hash that contains only default keys and values.
    #    c. Save the the array of hashes from step 2b
    #
    def save_creator
      self.creator_group ||= JSON.parse(self.creator.first) if self.creator.present?
      # remove Hash with empty values and nil
      clean_submitted_data ||= remove_hash_keys_with_empty_and_nil_values(self.creator_group)
      # Check if the hash keys are only those used for default values like position
      data = compare_hash_keys?(clean_submitted_data)

      if (self.creator_group.present? && clean_submitted_data.present? && data == false)
        creator_json = clean_submitted_data.to_json
        populate_creator_search_field(creator_json) unless self.instance_of?(Collection)
        self.creator = [creator_json]
      elsif (data == true || data == nil) && self.respond_to?(:creator_search)
        self.creator_search = []
        # save an empty array since the submitted data contains only default keys & values
        self.creator = []
      end
    end

    def save_contributor
      self.contributor_group ||= JSON.parse(self.contributor.first) if self.contributor.present?
      clean_incomplete_data(self.contributor_group) if self.contributor.present?
      clean_submitted_data ||= remove_hash_keys_with_empty_and_nil_values(self.contributor_group)
      data = compare_hash_keys?(clean_submitted_data)

      if (self.contributor_group.present? && clean_submitted_data.present? && data == false )
        contributor_json = clean_submitted_data.to_json
        self.contributor = [contributor_json]
      elsif data == true || data == nil
        self.contributor = []
      end
    end

    private

    #We parse the json in the an array before saving the value in creator_search
    def populate_creator_search_field(json_record)
      values = Ubiquity::ParseJson.new(json_record).data
      self.creator_search = values
    end

    #Check if the hash keys are only those used for default values like position
    def compare_hash_keys?(record)
      if record.present? && record.first.present?
        my_default_keys = get_default_hash_keys(record)
        keys_in_hash = record.map {|hash| hash.keys}.flatten.uniq
        (keys_in_hash == my_default_keys)
      else
        nil
      end
    end

    # remove hash keys with value of nil, "", and "NaN"
    def remove_hash_keys_with_empty_and_nil_values(data)
      if (data.present? && data.class == Array)
        new_data = data.map do |hash|
          ['contributor_orcid', 'contributor_isni', 'creator_orcid', 'creator_isni', 'editor_isni', 'editor_orcid'].each do|ele|
            hash[ele] = hash[ele].strip.chomp('/').split('/').last.gsub(/[^a-z0-9X-]/, '') if hash[ele].present?
          end
          hash.reject { |_k, v| v.nil? || v.to_s.empty? || v == "NaN" || v == [''] }
        end
        new_data.reject! { |hash| hash.blank? }
        remove_hash_with_default_keys(new_data)
      end
    end

    # remove any hash that contains only default keys and values.
    def remove_hash_with_default_keys(data)
      my_default_keys = get_default_hash_keys(data)
      new_data = data.reject do |hash|
        hash.keys.uniq == my_default_keys
      end
    end

    # data is an array of hash eg [{"contributor_organization_name"=>""}},{"contributor_name_type"=>"Personal"}]
    def get_default_hash_keys(data)
      if data.present? && data.first.present?
        #we get the first hash in the array and then get the first hash key
        record = data.first.keys.first || data

        splitted_record = record.split('_')

        # the value of record will be "contributor_organization_name" when using array of hash from the above comments
        # This means field name after the record.split will be 'contributor' and will change depending on the hash keys
        field_name ||= splitted_record.first
        return   ["#{field_name}_position"] if (data.length == 1 && splitted_record.last == "position")
        ["#{field_name}_name_type", "#{field_name}_position"]
      end
    end

    def transform_date_group(hash)
      # check the year field: `hash.first` returns the year key, for example: ["date_published_year", "2002"]
      if hash.first[1].present?
        date = ""
        # iterate over year, month, day to obtain a String in format: 'YYYY-MM-DD'
        # see 'all_forms_shared_behaviour'
        hash.each do |key, value|
          if value.present?
            date << '-' if key.exclude?('year') # add a `-` before month or day
            value = value.length < 2 ? "0#{value}" : value
            date << value
          else
            return date
          end
        end
        date
      end
    end

    def populate_date_field(date, name)
      if date.present? && name.present?
        Ubiquity::ParseDate.new(date, name).process_dates
      end
    end

    def get_field_name(data_hash)
      record = data_hash.first.keys.first || data_hash
      splitted_record = record.split('_')
      field_name ||= splitted_record.first
    end

    def clean_incomplete_data(data_hash)
      return if data_hash.empty?
      field_name = get_field_name(data_hash)
      data_hash.each do |hash|
        if (hash["#{field_name}_family_name"].blank? && hash["#{field_name}_organization_name"].blank?)
          hash.transform_values! { |v| nil }
        end
      end
    end
  end
end
