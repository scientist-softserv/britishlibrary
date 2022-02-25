# OVERRIDE HyraxDoi gem to not use urls for doi display
module Hyrax
  module DOI
    module DOIPresenterBehaviorDecorator
      # override from doi gem to skip link display
      def doi
        solr_document.doi.presence || solr_document.original_doi
      end
    end
  end
end

::Hyrax::DOI::DOIPresenterBehavior.prepend(Hyrax::DOI::DOIPresenterBehaviorDecorator)
