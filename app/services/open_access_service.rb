class OpenAccessService
  def self.unrestricted_use_files_for?(work:)
    case work

    # Scholarly articles
    when Article, ConferenceItem, GenericWork
      return true if peer_reviewed?(work: work) &&
                     work.record_level_file_version_declaration &&
                     work_has_public_files?(work: work, max_embargo_mths: 0) &&
                     coalition_s_funder?(work: work)

    # Books
    when Book, BookContribution
      return true if work_has_public_files?(work: work, max_embargo_mths: 12) &&
                     coalition_s_funder?(work: work)
    end

    false
  end

  # TODO: implement a way to find this
  def self.coalition_s_funder?(work:)
    # Funding from coalition S organisations - Derived from funders metadata and
    #   checked against list of coalition S funders
    return true if work.funder
    false
  end

  private_class_method :coalition_s_funder?

  def self.peer_reviewed?(work:)
    return true if work.refereed == 'Peer-reviewed'
    false
  end

  private_class_method :peer_reviewed?

  def self.work_has_public_files?(work:, max_embargo_mths:)
    open_filesets = work.file_sets.map(&:open_access?)
    return false unless open_filesets.any? { |ab| (ab == true) }
    return true if embargo_within_max_allowed_age?(work: work, max_embargo_mths: max_embargo_mths)
    false
  end

  private_class_method :work_has_public_files?

  def self.embargo_within_max_allowed_age?(work:, max_embargo_mths:)
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

  private_class_method :embargo_within_max_allowed_age?

  # find the embargo age using the embargo's created date and dates out of the history info
  def self.embargo_age(embargo_added:, history_msg:)
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

  private_class_method :embargo_age
end
