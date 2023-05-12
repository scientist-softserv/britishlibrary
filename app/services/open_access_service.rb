class OpenAccessService
  include MultipleMetadataFieldsHelper

  def initialize(work:)
    @work = work
  end
  attr_reader :work

  def unrestricted_use_files?
    case work
    # Scholarly articles
    when Article, ConferenceItem, GenericWork
      return true if peer_reviewed? &&
                     ActiveModel::Type::Boolean.new.cast(work.record_level_file_version_declaration) &&
                     public_files?(max_embargo_mths: 0) &&
                     coalition_s?
    # Books
    when Book, BookContribution
      return true if public_files?(max_embargo_mths: 12) &&
                     coalition_s?
    end
    false
  end

  private

    def coalition_s?
      return false unless work.funder
      # parse funder string into a valid hash and break this into an array of DOI's
      data_hash = get_model(work.funder, nil, 'funder')
      funder_doi_array = data_hash&.map { |c| [c['funder_doi']].reject(&:blank?).join(', ') } || []
      # process the array of DOI's, looking for the "broader" attribute which tells us this is a Plan S funder.
      funder_doi_array.each do |doi|
        return true if funder_doi?(doi: doi)
      end
      false
    end

    DOI_REGEX = %r{^https?://.*doi\.org/(.+)$}
    def funder_doi?(doi:)
      # DOIs can begin with either http://doi.org or https://dx.doi.org so we verify using only the numeric portion
      cleaned_doi = doi.gsub(DOI_REGEX, '\1')
      return true unless PlanSFunder.where(funder_doi: cleaned_doi, funder_status: 'active').empty?
      false
    end

    def peer_reviewed?
      return true if work.refereed == 'Peer-reviewed'
      false
    end

    def public_files?(max_embargo_mths:)
      open_filesets = work.file_sets.map(&:open_access?)
      return false unless open_filesets.any? { |ab| (ab == true) }
      return true if embargo_within_max_allowed_age?(max_embargo_mths: max_embargo_mths)
      false
    end

    def embargo_within_max_allowed_age?(max_embargo_mths:)
      return true unless work.embargo_id
      embargo = work.embargo
      return false if embargo.embargo_release_date
      return true unless embargo.embargo_history
      return false if max_embargo_mths.zero?
      age = embargo_age(embargo_added: embargo.create_date,
                        history_msg: embargo.embargo_history)
      return true if age < max_embargo_mths
      false
    end

    # find the embargo age using the embargo's created date and dates out of the history info
    def embargo_age(embargo_added:, history_msg:)
      # Explanation:
      # Embargo release date is transient... once deactivated, it is only available in the history message
      # The message comes from hydra-access-controls.en.yml, with the following text:
      #   An %{state} embargo was deactivated on %{deactivate_date}.  Its release date was %{release_date}.
      #   Visibility during embargo was %{visibility_during} and intended visibility after embargo was %{visibility_after}
      # Multiple deactivated messages can exist in the history array. The last is the most recent embargo release action.
      # It is also important to note that the embargo is not necessarily deactivated on the embargo release date, but the
      # work IS considered open as of the release date. So we need to look for the earlier of these two dates.

      # pull deactivated & released dates out of the most recent history message
      (deactivated, released) = history_msg.last.scan(/\d{4}-\d{2}-\d{2}/)
      # parse into Date objects
      deactivated_date = Date.parse(deactivated)
      embargo_date = Date.parse(released)
      embargo_ended = [deactivated_date, embargo_date].min
      # find the number of months between the two dates (NOT rounded)
      (embargo_ended - embargo_added).to_f / 365 * 12
    end
end
