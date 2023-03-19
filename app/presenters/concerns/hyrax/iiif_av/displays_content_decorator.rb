module Hyrax
  module IiifAv
    # main reasons for this decorator is to override variable names from hyrax-iiif_av
    #   solr_document => object
    #   current_ability => @ability
    #   request.base_url => hostname
    # also to remove #auth_service since it was not working for now
    module DisplaysContentDecorator
      def display_content
        return nil unless display_content_allowed?

        return image_content if solr_document.image?
        return video_content if solr_document.video?
        return audio_content if solr_document.audio?
        return mesh_content if solr_document.mesh?
      end

      private

        def content_supported?
          solr_document.video? || solr_document.audio? || solr_document.image? || solr_document.mesh?
        end

        def solr_document
          defined?(super) ? super : object
        end

        def current_ability
          defined?(super) ? super : @ability
        end

        Request = Struct.new(:base_url, keyword_init: true)

        def request
          Request.new(base_url: hostname)
        end

        def mesh_content
          IIIFManifest::V3::DisplayContent.new(
            Hyrax::Engine.routes.url_helpers.download_url(id, file: 'glb', protocol: 'https'),
            type: 'Model',
            format: solr_document.mime_type
          )
        end

        def image_content
          return nil unless latest_file_id

          url = Hyrax.config.iiif_image_url_builder.call(
            latest_file_id,
            request.base_url,
            Hyrax.config.iiif_image_size_default
          )

          # Serving up only prezi 3
          image_content_v3(url)
        end

        def image_content_v3(url)
          # @see https://github.com/samvera-labs/iiif_manifest
          IIIFManifest::V3::DisplayContent.new(
            url,
            type: 'Image',
            format: 'image/jpeg',
            width: width,
            height: height,
            iiif_endpoint: iiif_endpoint(latest_file_id)
          )
        end

        def video_display_content(_url, label = '')
          width = Array(solr_document.width).first.try(:to_i) || 320
          height = Array(solr_document.height).first.try(:to_i) || 240
          duration = conformed_duration_in_seconds
          IIIFManifest::V3::DisplayContent.new(
            Hyrax::IiifAv::Engine.routes.url_helpers.iiif_av_content_url(
              solr_document.id, label: label, host: request.base_url
            ),
            type: 'Video',
            format: 'video/mp4',
            label: label,
            duration: duration,
            width: width,
            height: height
          )
        end

        def audio_content
          streams = stream_urls
          if streams.present?
            streams.collect { |label, url| audio_display_content(url, label) }
          else
            [audio_display_content(download_path('mp3'), 'mp3')]
          end
        end

        def audio_display_content(_url, label = '')
          duration = conformed_duration_in_seconds
          IIIFManifest::V3::DisplayContent.new(
            Hyrax::IiifAv::Engine.routes.url_helpers.iiif_av_content_url(
              solr_document.id, label: label, host: request.base_url
            ),
            type: 'Sound',
            format: 'audio/mp3',
            label: label,
            duration: duration
          )
        end

        def conformed_duration_in_seconds
          if Array(solr_document.duration)&.first&.count(':') == 3
            # takes care of milliseconds like ["0:0:01:001"]
            Time.zone.parse(Array(solr_document.duration).first.sub(/.*\K:/, '.')).seconds_since_midnight
          elsif Array(solr_document.duration)&.first&.include?(':')
            # if solr_document.duration evaluates to something like ["0:01:00"] which will get converted to seconds
            Time.zone.parse(Array(solr_document.duration).first).seconds_since_midnight
          else
            # handles cases if solr_document.duration evaluates to something like ['25 s']
            Array(solr_document.duration).first.try(:to_f)
          end ||
            400.0
        end
    end
  end
end

Hyrax::IiifAv::DisplaysContent.prepend(Hyrax::IiifAv::DisplaysContentDecorator)
