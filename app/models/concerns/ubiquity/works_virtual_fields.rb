module Ubiquity
  module WorksVirtualFields
    extend ActiveSupport::Concern

    included do
      before_save :save_funder
      before_save :save_editor
      before_save :save_alternate_identifier
      before_save :save_related_identifier
      before_save :save_date_published, :save_date_accepted, :save_date_submitted,
                  :save_event_date, :save_related_exhibition_date
      before_save :save_current_he_institution

      # TODO: ~alignment: relates to doi and work expiry
      # after_save :update_external_service_record, :create_work_service_if_embargo_or_lease

      #These are used in the forms to populate fields that will be stored in json fields
      #The json fields in this case are alternate_identifier, related_identifier and current_he_institution
      attr_accessor :funder_group, :alternate_identifier_group, :related_identifier_group,
                    :date_published_group, :date_accepted_group, :date_submitted_group,
                    :event_date_group, :related_exhibition_date_group, :current_he_institution_group, :editor_group
    end

    private

      # TODO: ~alignment: relates to doi
      # def update_external_service_record
      # exter = ExternalService.where(draft_doi: self.draft_doi).first
      # if exter.try(:work_id).blank?
      # begin
      # exter && exter.update!(work_id: self.id)
      # rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid => e
      # puts'ExternalService record not saved in the model'
      # AddWorkIdToExternalServiceJob.perform_later(self.id, self.draft_doi, self.account_cname)
      # end
      # end
      # end

      # TODO: ~alignment: relates to work expiry
      # def create_work_service_if_embargo_or_lease
      # if under_embargo? || active_lease?
      # create_work_expiry_service
      # end
      # end

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

      def save_funder
        self.funder_group ||= Ubiquity::JsonValidator.valid_json?(funder.try(:first)) ? JSON.parse(funder.first) : nil if funder.present?
        clean_incomplete_data_for_funder(self.funder_group) if funder.present?
        clean_submitted_data ||= remove_hash_keys_with_empty_and_nil_values(self.funder_group)
        data = compare_hash_keys?(clean_submitted_data)
        if self.funder_group.present? && clean_submitted_data.present? && data == false
          funder_json = clean_submitted_data.to_json
          self.funder = [funder_json]
        elsif data == true || data.nil?
          self.funder = []
        end
      end

      def save_editor
        self.editor_group ||= JSON.parse(editor.first) if editor.present?
        clean_incomplete_data(self.editor_group) if editor.present?
        clean_submitted_data ||= remove_hash_keys_with_empty_and_nil_values(self.editor_group)
        data = compare_hash_keys?(clean_submitted_data)
        if self.editor_group.present? && clean_submitted_data.present? && data == false
          editor_json = clean_submitted_data.to_json
          self.editor = [editor_json]
        elsif data == true || data.nil?
          self.editor = []
        end
      end

      def save_related_identifier
        self.related_identifier_group ||= JSON.parse(related_identifier.first) if related_identifier.present?
        clean_submitted_data ||= remove_hash_keys_with_empty_and_nil_values(self.related_identifier_group)
        data = compare_hash_keys?(clean_submitted_data)
        if self.related_identifier_group.present? && clean_submitted_data.present? && data == false
          related_identifier_json = clean_submitted_data.to_json
          self.related_identifier = [related_identifier_json]
        elsif data == true || data.nil?
          self.related_identifier = []
        end
      end

      def save_alternate_identifier
        self.alternate_identifier_group ||= JSON.parse(alternate_identifier.first) if alternate_identifier.present?
        clean_submitted_data ||= remove_hash_keys_with_empty_and_nil_values(self.alternate_identifier_group)
        data = compare_hash_keys?(clean_submitted_data)
        if self.alternate_identifier_group.present? && clean_submitted_data.present? && data == false
          #remove any empty hash in the array
          clean_submitted_data -= [{}]
          alternate_identifier_json = clean_submitted_data.to_json
          self.alternate_identifier = [alternate_identifier_json]
        elsif data == true || data.nil?
          self.alternate_identifier = []
        end
      end

      def save_date_published
         save_single_date('date_published')
      end
      def save_date_accepted
        save_single_date('date_accepted')
      end
      def save_date_submitted
        save_single_date('date_submitted')
      end
      def save_single_date(value_name)
        value = send(value_name)
        # We have value and that value is a string
        new_value = populate_date_field(value, value_name) if value.present? && value.class == String
        value_group = eval("#{value_name}_group")
        # No existing value so we set the value_group to new_value
        value_group ||= new_value if new_value.present? && value_group.blank?
        self[value_name] = transform_date_group(value_group.first) if value_group
      end

      def save_event_date
         save_multiple_date('event_date')
      end
      def save_related_exhibition_date
        save_multiple_date('related_exhibition_date')
      end
      def save_multiple_date(value_name)

        value = send(value_name)
        # If date is present and a String (rather than an ActiveTriple) use populate_date_field 
        # to create a new_value that is a group format i.e. array of hashes with 
        # {'field_name'_year=>XX, 'field_name'_month=>XX, ...} 
        new_value = populate_date_field(value, value_name) if value.present? && value.class == String

        # Use new_value if we don't already have a value_group to set the value_group
        value_group = eval("#{value_name}_group")
        value_group ||= new_value if new_value.present? && value_group.blank?

        # If value_group is blank _and_ there is no new_value use value (ActiveTriple) and 
        # populate_date_field to create the group format date (see above) and set the value_group
        if value&.first.present? && value_group.blank? 
          value_group = []
          value.each{ |d| value_group+=populate_date_field(d, value_name) }
        end

        # Now we can resonably sure that all our dates are in the 'group' format output by populate_date_field
        # We can transform the dates into strings and put them in an array... why like this? ¯\_(")_/¯
        dates = []
        value_group&.each { |e| dates << transform_date_group(e).to_s }
        self[value_name] = dates.reject(&:blank?)
      end

      def save_current_he_institution
        if current_he_institution.present?
          self.current_he_institution_group ||= JSON.parse(current_he_institution.first) if Ubiquity::JsonValidator.valid_json?(current_he_institution.first)
        end

        clean_submitted_data ||= remove_hash_keys_with_empty_and_nil_values(self.current_he_institution_group)
        data = compare_hash_keys?(clean_submitted_data)
        if self.current_he_institution_group.present? && clean_submitted_data.present? && data == false
          current_he_institution_json = clean_submitted_data.to_json
          self.current_he_institution = [current_he_institution_json]
        elsif data == true || data.nil?
          self.current_he_institution = []
        end
      end

      def clean_incomplete_data_for_funder(data_hash)
        return if data_hash.blank?
        data_hash.each do |hash|
          hash.transform_values! { |_v| nil } if hash["funder_name"].blank?
        end
      end
  end
end
