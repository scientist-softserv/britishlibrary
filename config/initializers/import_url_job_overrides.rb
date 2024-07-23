ImportUrlJob.class_eval do

  def copy_remote_file(uri, name, headers = {})
    filename = File.basename(name)
    dir = Dir.mktmpdir
    Rails.logger.debug("ImportUrlJob: Copying <#{uri}> to #{dir}")

    File.open(File.join(dir, filename), 'wb') do |f|
      begin
        write_file(uri, f, headers)
        yield f
      rescue StandardError => e
        STDERR.puts("IMPORT URL ERROR: #{e}")
        send_error(e.message)
      end
    end
    Rails.logger.debug("ImportUrlJob: Closing #{File.join(dir, filename)}")
  end

  def send_error(error_message)
    user = User.find_by_user_key(file_set.depositor)
    @file_set.errors.add('Error:', error_message)
    Hyrax.config.callback.run(:after_import_url_failure, @file_set, user)
    Rails.logger.debug("IMPORT URL ERROR: #{error_message}")
    @operation.fail!(@file_set.errors.full_messages.join(' '))
  end

end

