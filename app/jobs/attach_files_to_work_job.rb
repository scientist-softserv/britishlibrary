# [BL-override] add virus checking to job
# Converts UploadedFiles into FileSets and attaches them to works.
class AttachFilesToWorkJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # @param [ActiveFedora::Base] work - the work object
  # @param [Array<Hyrax::UploadedFile>] uploaded_files - an array of files to attach
  def perform(work, uploaded_files, **work_attributes)
    validate_files!(uploaded_files)
    depositor = proxy_or_depositor(work)
    user = User.find_by_user_key(depositor)
    work_permissions = work.permissions.map(&:to_hash)
    metadata = visibility_attributes(work_attributes)
    uploaded_files.each do |uploaded_file|
      # [BL-override] check all files for viruses
      STDERR.puts "######################################################"
      STDERR.puts " Uploaded_file before virus_check! #{uploaded_file}"
      STDERR.puts "######################################################"
      #virus_check!(uploaded_file)
      next if uploaded_file.file_set_uri.present?
      STDERR.puts " New file is not infected :) #{uploaded_file}"
      actor = Hyrax::Actors::FileSetActor.new(FileSet.create, user)
      uploaded_file.update(file_set_uri: actor.file_set.uri)
      actor.file_set.permissions_attributes = work_permissions
      actor.create_metadata(metadata)
      actor.create_content(uploaded_file)
      actor.attach_to_work(work)
    end
    # [BL-override] Log viruses
    #rescue VirusDetectedError => error
    #Rails.logger.error "Virus encountered while processing work #{work.id}.\n" "\t#{error.message}"
  end

  # [BL-override] Add virus detection error class
  class VirusDetectedError < RuntimeError; end

  private

    # The attributes used for visibility - sent as initial params to created FileSets.
    def visibility_attributes(attributes)
      attributes.slice(:visibility, :visibility_during_lease,
                       :visibility_after_lease, :lease_expiration_date,
                       :embargo_release_date, :visibility_during_embargo,
                       :visibility_after_embargo)
    end

    def validate_files!(uploaded_files)
      uploaded_files.each do |uploaded_file|
        next if uploaded_file.is_a? Hyrax::UploadedFile
        raise ArgumentError, "Hyrax::UploadedFile required, but #{uploaded_file.class} received: #{uploaded_file.inspect}"
      end
    end

    ##
    # A work with files attached by a proxy user will set the depositor as the intended user
    # that the proxy was depositing on behalf of. See tickets #2764, #2902.
    def proxy_or_depositor(work)
      work.on_behalf_of.presence || work.depositor
    end

    # [hyc-override] add virus checking method
    def virus_check!(uploaded_file)
      rails_root = Rails.root.to_s
      return unless Hyc::VirusScanner.infected?("#{rails_root}/public#{uploaded_file.file}")
      carrierwave_file = uploaded_file.file.file
      carrierwave_file.delete
      raise(VirusDetectedError, carrierwave_file.filename)
    end
end
