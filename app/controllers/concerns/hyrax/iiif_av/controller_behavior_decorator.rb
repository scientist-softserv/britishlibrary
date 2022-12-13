module Hyrax
  module IiifAv
    module ControllerBehaviorDecorator
      def manifest
        add_iiif_header

        headers['Access-Control-Allow-Origin'] = '*'

        json = Hyrax::ManifestBuilderService.manifest_for(presenter: iiif_manifest_presenter, iiif_manifest_factory: manifest_factory)

        respond_to do |wants|
          wants.json { render json: json }
          wants.html { render json: json }
        end
      end
    end
  end
end

Hyrax::IiifAv::ControllerBehavior.prepend(Hyrax::IiifAv::ControllerBehaviorDecorator)
