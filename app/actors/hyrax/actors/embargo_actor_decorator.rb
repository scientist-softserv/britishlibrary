module Hyrax
  module Actors
    module EmbargoActorDecorator
      def destroy
        super
        Hyrax::DOI::RegisterDOIJob.conditionally_create_or_update_doi_for(work)
      end
    end
  end
end
