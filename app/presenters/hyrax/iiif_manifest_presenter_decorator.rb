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
        super && (image? || audio? || video? || mesh?)
      end
    end
  end
end

Hyrax::IiifManifestPresenter.prepend(Hyrax::IiifManifestPresenterDecorator)
Hyrax::IiifManifestPresenter::DisplayImagePresenter
  .prepend(Hyrax::IiifManifestPresenterDecorator::DisplayImagePresenterDecorator)
