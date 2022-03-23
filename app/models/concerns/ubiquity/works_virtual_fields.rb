module Ubiquity
  module WorksVirtualFields
    extend ActiveSupport::Concern

    included do

      before_save :save_funder, unless: proc { self.instance_of?(Collection) }
      before_save :save_editor, unless: proc { self.instance_of?(Collection) }
      before_save :save_alternate_identifier, unless: proc { self.instance_of?(Collection) }
      before_save :save_related_identifier, unless: proc { self.instance_of?(Collection) }
      before_save :save_date_published, :save_date_accepted, :save_date_submitted,
                  :save_event_date, :save_related_exhibition_date, unless: proc { self.instance_of?(Collection) }
      before_save :save_current_he_institution, unless: proc { self.instance_of?(Collection) }

      # TODO ~alignment: relates to doi and work expiry
      # after_save :update_external_service_record, :create_work_service_if_embargo_or_lease

      #These are used in the forms to populate fields that will be stored in json fields
      #The json fields in this case are alternate_identifier, related_identifier and current_he_institution
      attr_accessor :funder_group, :alternate_identifier_group, :related_identifier_group,
                    :date_published_group, :date_accepted_group, :date_submitted_group,
                    :event_date_group, :related_exhibition_date_group, :current_he_institution_group, :editor_group
    end

    private

      # TODO ~alignment: relates to doi
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

      # TODO ~alignment: relates to work expiry
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
      self.funder_group ||= Ubiquity::JsonValidator.valid_json?( self.funder.try(:first) ) ? JSON.parse(self.funder.first) : nil if self.funder.present?
      clean_incomplete_data_for_funder(self.funder_group) if self.funder.present?
      clean_submitted_data ||= remove_hash_keys_with_empty_and_nil_values(self.funder_group)
      data = compare_hash_keys?(clean_submitted_data)
      if (self.funder_group.present? && clean_submitted_data.present? && data == false )
        funder_json = clean_submitted_data.to_json
        self.funder = [funder_json]
      elsif data == true || data == nil
        self.funder = []
      end
    end

    def save_editor
      self.editor_group ||= JSON.parse(self.editor.first) if self.editor.present?
      clean_incomplete_data(self.editor_group) if self.editor.present?
      clean_submitted_data ||= remove_hash_keys_with_empty_and_nil_values(self.editor_group)
      data = compare_hash_keys?(clean_submitted_data)
      if (self.editor_group.present? && clean_submitted_data.present? && data == false )
        editor_json = clean_submitted_data.to_json
        self.editor = [editor_json]
      elsif  data == true || data == nil
        self.editor = []
      end
    end

    def save_related_identifier
      self.related_identifier_group ||= JSON.parse(self.related_identifier.first) if self.related_identifier.present?
      clean_submitted_data ||= remove_hash_keys_with_empty_and_nil_values(self.related_identifier_group)
      data = compare_hash_keys?(clean_submitted_data)
      if (self.related_identifier_group.present?  && clean_submitted_data.present? && data == false)
        related_identifier_json = clean_submitted_data.to_json
        self.related_identifier = [related_identifier_json]
      elsif data == true || data == nil
        self.related_identifier = []
      end
    end

    def save_alternate_identifier
      self.alternate_identifier_group ||= JSON.parse(self.alternate_identifier.first) if self.alternate_identifier.present?
      clean_submitted_data ||= remove_hash_keys_with_empty_and_nil_values(self.alternate_identifier_group)
      data = compare_hash_keys?(clean_submitted_data)
      if (self.alternate_identifier_group.present? && clean_submitted_data.present? && data == false)
        #remove any empty hash in the array
        clean_submitted_data = clean_submitted_data - [{}]
        alternate_identifier_json = clean_submitted_data.to_json
        self.alternate_identifier = [alternate_identifier_json]
      elsif data == true || data == nil
        self.alternate_identifier = []
      end
    end

    def save_date_published
      date ||= self.date_published if (self.date_published.present? && self.date_published.class == String)
      new_value = populate_date_field(date, date_published)
      self.date_published_group ||= new_value  if (new_value.present? && (not self.date_published_group.present?) )
      self.date_published = transform_date_group(date_published_group.first) if date_published_group
    end

    def save_date_accepted
      date ||= self.date_accepted if (self.date_accepted.present? && self.date_accepted.class == String)
      new_value = populate_date_field(date, date_accepted)
      self.date_accepted_group ||= new_value  if (new_value.present? && (not self.date_accepted_group.present?) )
      self.date_accepted = transform_date_group(date_accepted_group.first) if date_accepted_group
    end

    def save_date_submitted
      date ||= self.date_submitted if (self.date_submitted.present? && self.date_submitted.class == String)
      new_value = populate_date_field(date, date_accepted)
      self.date_submitted_group ||= new_value  if (new_value.present? && (not self.date_submitted_group.present?) )
      self.date_submitted = transform_date_group(date_submitted_group.first) if date_submitted_group
    end

    def save_event_date
      date ||= self.event_date if (self.event_date.present? && self.event_date.class == String)
      new_value = populate_date_field(date, event_date)
      self.event_date_group ||= new_value if (new_value.present? && (self.event_date_group.blank?) )
      dates = []
      if event_date_group
        event_date_group.each do |e|
          dates << transform_date_group(e).to_s
        end
      end
      self.event_date = dates.reject(&:blank?)
    end

    def save_related_exhibition_date
      date ||= self.related_exhibition_date if (self.related_exhibition_date.present? && self.related_exhibition_date.class == String)
      new_value = populate_date_field(date, related_exhibition_date)
      self.related_exhibition_date_group ||= new_value if (new_value.present? && (self.related_exhibition_date_group.blank?) )
      dates = []
      if related_exhibition_date_group
        related_exhibition_date_group.each do |e|
          dates << transform_date_group(e).to_s
        end
      end
      self.related_exhibition_date = dates.reject(&:blank?)
    end

    def save_current_he_institution
      self.current_he_institution_group ||=  Ubiquity::JsonValidator.valid_json?(self.current_he_institution.first) ?
                                  JSON.parse(self.current_he_institution.first) : nil if self.current_he_institution.present?

      clean_submitted_data ||= remove_hash_keys_with_empty_and_nil_values(self.current_he_institution_group)
      data = compare_hash_keys?(clean_submitted_data)
      if (self.current_he_institution_group.present? && clean_submitted_data.present? && data == false )
        current_he_institution_json = clean_submitted_data.to_json
        self.current_he_institution = [current_he_institution_json]
      elsif data == true || data == nil
        self.current_he_institution = []
      end
    end

    private

    def clean_incomplete_data_for_funder(data_hash)
      return if data_hash.blank?
      data_hash.each do |hash|
        if hash["funder_name"].blank?
          hash.transform_values! { |v| nil }
        end
      end
    end
  end
end
