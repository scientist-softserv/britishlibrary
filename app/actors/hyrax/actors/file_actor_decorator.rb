module Hyrax
  module Actors
    # Actions for a file identified by file_set and relation (maps to use predicate)
    # @note Spawns asynchronous jobs
    module FileActorDecorator
      def ingest_file(io)
        Rails.logger.error("[FileActor] starting write for #{file_set.id}")
        if io.size.to_i >= 1.gigabytes
          Rails.logger.error("[FileActor] Uploading directly to S3 for file_set #{file_set.id}")
          digest = `sha1sum #{io.path}`.split.first
          file_set.s3_only = digest
          s3_object = Aws::S3::Object.new(ENV['AWS_BUCKET'], digest)
          s3_object.upload_file(io.path) unless s3_object.exists?
          Hydra::Works::AddExternalFileToFileSet.call(file_set, s3_object.public_url, relation)
          # how do we make sure the sha gets indexed?
        else
          Rails.logger.error("[FileActor] writing to fcrepo #{file_set.id}")
          # Skip versioning because versions will be minted by VersionCommitter as necessary during save_characterize_and_record_committer.
          Hydra::Works::AddFileToFileSet.call(file_set,
                                              io,
                                              relation,
                                              versioning: false)
        end
        return false unless file_set.save
        repository_file = related_file
        Hyrax::VersioningService.create(repository_file, user)
        pathhint = io.uploaded_file.uploader.path if io.uploaded_file # in case next worker is on same filesystem
        CharacterizeJob.perform_later(file_set, repository_file.id, pathhint || io.path)
      end
    end
  end
end

Hyrax::Actors::FileActor.prepend(Hyrax::Actors::FileActorDecorator)
