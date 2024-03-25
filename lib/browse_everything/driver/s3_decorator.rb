# frozen_string_literal: true

# OVERRIDE BrowseEverything v1.1.2 to add file_size for S3 files

module BrowseEverything
  module Driver
    module S3Decorator
      def link_for(path)
        obj = bucket.object(full_path(path))
        obj_head = obj.head
        file_size = obj_head.content_length

        extras = {
          file_name: File.basename(path),
          file_size: file_size,
          expires: (config[:expires_in] if config[:response_type] == :signed_url)
        }.compact

        url = case config[:response_type].to_sym
              when :signed_url then obj.presigned_url(:get, expires_in: config[:expires_in])
              when :public_url then obj.public_url
              when :s3_uri     then "s3://#{obj.bucket_name}/#{obj.key}"
              end

        [url, extras]
      end
    end
  end
end

BrowseEverything::Driver::S3.prepend(BrowseEverything::Driver::S3Decorator)
