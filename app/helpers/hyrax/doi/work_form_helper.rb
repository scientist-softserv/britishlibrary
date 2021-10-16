# frozen_string_literal: true
# OVERRIDE Hyrax::DOI 0.2.0 to hide tab if doi is disabled for a tenant

module Hyrax
  module DOI
    module WorkFormHelper
      def form_tabs_for(form:)
        if form.model_class.ancestors.include?(Hyrax::DOI::DOIBehavior) &&
            (current_account.doi_reader || current_account.doi_minting)
          super.prepend("doi")
        else
          super
        end
      end
    end
  end
end
