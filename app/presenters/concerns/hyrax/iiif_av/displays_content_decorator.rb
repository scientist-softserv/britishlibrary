module Hyrax
  module IiifAv
    module DisplaysContentDecorator
      # main reasons for this decorator is to override variable names from hyrax-iiif_av
      #   solr_document => object
      #   current_ability => @ability
      #   request.base_url => hostname
      # also to remove #auth_service since it was not working for now
      def display_content
        return nil unless display_content_allowed?

        return image_content if object.image?
        return video_content if object.video?
        return audio_content if object.audio?
      end

      private

        def display_content_allowed?
          content_supported? && @ability.can?(:read, id)
        end

        def content_supported?
          object.video? || object.audio? || object.image?
        end

        def image_content
          return nil unless latest_file_id

          url = Hyrax.config.iiif_image_url_builder.call(
            latest_file_id,
            hostname,
            Hyrax.config.iiif_image_size_default
          )

          image_content_v3(url)
        end

        def image_content_v3(url)
          # @see https://github.com/samvera-labs/iiif_manifest
          IIIFManifest::V3::DisplayContent.new(url,
                                               format: object.mime_type,
                                               width: width,
                                               height: height,
                                               type: 'Image',
                                               iiif_endpoint: iiif_endpoint(latest_file_id, base_url: hostname))
        end

        def video_content
          # @see https://github.com/samvera-labs/iiif_manifest
          streams = stream_urls
          if streams.present?
            streams.collect { |label, url| video_display_content(url, label) }
          else
            [
              video_display_content(download_path('mp4'), 'mp4'),
              # commenting out webm to clean up manifest with only one derivative
              # video_display_content(download_path('webm'), 'webm')
            ]
          end
        end

        def video_display_content(_url, label = '')
          IIIFManifest::V3::DisplayContent.new(Hyrax::IiifAv::Engine.routes.url_helpers.iiif_av_content_dcurl(object.id, label: label, host: hostname),
                                               label: label,
                                               width: Array(object.width).first.try(:to_i) || 320,
                                               height: Array(object.height).first.try(:to_i) || 240,
                                               duration: Array(object.duration).first.try(:to_i) || 400.0,
                                               type: 'Video',
                                               format: object.mime_type)
        end

        def audio_content
          streams = stream_urls
          if streams.present?
            streams.collect { |label, url| audio_display_content(url, label) }
          else
            [
              # commenting out ogg to clean up manifest with only one derivative
              # audio_display_content(download_path('ogg'), 'ogg'),
              audio_display_content(download_path('mp3'), 'mp3')
            ]
          end
        end

        def audio_display_content(_url, label = '')
          IIIFManifest::V3::DisplayContent.new(Hyrax::IiifAv::Engine.routes.url_helpers.iiif_av_content_url(object.id, label: label, host: hostname),
                                               label: label,
                                               duration: Array(object.duration).first.try(:to_i) || 400.0,
                                               type: 'Sound',
                                               format: object.mime_type)
        end

        def download_path(extension)
          Hyrax::Engine.routes.url_helpers.download_url(object, file: extension, host: hostname)
        end

        def stream_urls
          return {} if object['derivatives_metadata_ssi'].blank?
          files_metadata = JSON.parse(object['derivatives_metadata_ssi'])
          file_locations = files_metadata.select { |f| f['file_location_uri'].present? }
          streams = {}
          if file_locations.present?
            file_locations.each do |f|
              streams[f['label']] = Hyrax::IiifAv.config.iiif_av_url_builder.call(
                f['file_location_uri'],
                hostname
              )
            end
          end
          streams
        end
    end
  end
end

Hyrax::IiifAv::DisplaysContent.prepend(Hyrax::IiifAv::DisplaysContentDecorator)
