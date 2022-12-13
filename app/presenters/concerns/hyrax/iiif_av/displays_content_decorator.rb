module Hyrax
  module IiifAv
    module DisplaysContentDecorator
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

        def video_content
          # @see https://github.com/samvera-labs/iiif_manifest
          streams = stream_urls
          if streams.present?
            streams.collect { |label, url| video_display_content(url, label) }
          else
            [video_display_content(download_path('mp4'), 'mp4')]
          end
        end

        def video_display_content(_url, label = '')
          IIIFManifest::V3::DisplayContent.new(Hyrax::IiifAv::Engine.routes.url_helpers.iiif_av_content_url(object.id, label: label, host: hostname),
                                               label: label,
                                               width: Array(object.width).first.try(:to_i) || 320,
                                               height: Array(object.height).first.try(:to_i) || 240,
                                               duration: Array(object.duration).first.try(:to_i) || 400.0,
                                               type: 'Video',
                                               format: object.mime_type)
        end

        def download_path(extension)
          Hyrax::Engine.routes.url_helpers.download_url(object, file: extension, host: hostname)
        end

        def stream_urls
          return {} unless object['derivatives_metadata_ssi'].present?
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
