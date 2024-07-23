ImportUrlJob.class_eval do

  def send_error(error_message)
    user = User.find_by_user_key(file_set.depositor)
    @file_set.errors.add('Error:', error_message)
    Hyrax.config.callback.run(:after_import_url_failure, @file_set, user)
    Rails.logger.debug("IMPORT URL ERROR: #{error_message}")
    @operation.fail!(@file_set.errors.full_messages.join(' '))
  end

end

