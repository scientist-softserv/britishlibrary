# frozen_string_literal: true

# Included in any work that requires saving version number. Currently used in Dataset and GenericWork
module Ubiquity
  module VersionMetadataModelConcern
    extend ActiveSupport::Concern
    # TODO: Rob include Ubiquity::AllModelsVirtualFields

    included do
      before_save :save_version
    end

    private

      def save_version
        self.version = version_number
      end
  end
end
