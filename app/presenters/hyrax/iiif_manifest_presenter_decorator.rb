module Hyrax
  module IiifManifestPresenterDecorator
    attr_writer :iiif_version

    def iiif_version
      @iiif_version || 3
    end

    module DisplayImagePresenterDecorator
      include Hyrax::IiifAv::DisplaysContent
      # override Hyrax method to avoid double items in the manifest
      def display_image; end

      # override Hyrax to keep pdfs from gumming up the v3 manifest
      # in app/presenters/hyrax/iiif_manifest_presenter.rb
      def file_set?
        super && (image? || audio? || video?)
      end

      ##
      # Creates a display image only where #model is an image.
      #
      # @return [IIIFManifest::DisplayImage] the display image required by the manifest builder.
      def display_image
        return nil unless model.image?
        return nil unless latest_file_id

        IIIFManifest::DisplayImage
          .new(display_image_url(hostname),
               format: image_format(alpha_channels),
               width: width,
               height: height,
               iiif_endpoint: iiif_endpoint(latest_file_id, base_url: hostname))
      end

      def display_image_url(base_url)
        if ENV['SERVERLESS_IIIF_URL'].present?
          Hyrax.config.iiif_image_url_builder.call(
            latest_file_id,
            ENV['SERVERLESS_IIIF_URL'],
            Hyrax.config.iiif_image_size_default
          ).gsub(%r{images/}, '')
        else
          super
        end
      end
  
      def iiif_endpoint(file_id, base_url: request.base_url)
        if ENV['SERVERLESS_IIIF_URL'].present?
          IIIFManifest::IIIFEndpoint.new(
            File.join(ENV['SERVERLESS_IIIF_URL'], file_id),
            profile: Hyrax.config.iiif_image_compliance_level_uri
          )
        else
          super
        end
      end
  
      def hostname
        @hostname || 'localhost'
      end
  
      ##
      # @return [Boolean] false
      def work?
        false
      end
  
        private
  
          def latest_file_id
            if ENV['SERVERLESS_IIIF_URL'].present?
              serverless_latest_file_id
            else
              super
            end
          end
  
          def serverless_latest_file_id
            @latest_file_id ||= digest_sha1
          end
    end
  end
end

Hyrax::IiifManifestPresenter.prepend(Hyrax::IiifManifestPresenterDecorator)
Hyrax::IiifManifestPresenter::DisplayImagePresenter
  .prepend(Hyrax::IiifManifestPresenterDecorator::DisplayImagePresenterDecorator)
