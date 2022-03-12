# frozen_string_literal: true

module Hyrax
  module DOI
    class RegisterDOIJob < ApplicationJob
      include Rails.application.routes.url_helpers
      # For link_to
      include ActionView::Helpers

      queue_as Hyrax.config.ingest_queue_name

      ##
      # @param model [ActiveFedora::Base]
      # @param registrar [String] Note this is a string and not a symbol because ActiveJob cannot serialize a symbol
      # @param registrar_opts [Hash]
      def perform(model, registrar: Hyrax.config.identifier_registrars.keys.first, registrar_opts: {})
        Hyrax::Identifier::Dispatcher
          .for(registrar.to_sym, **registrar_opts)
          .assign_for!(object: model, attribute: :doi)
      # rubocop:disable Style/RescueStandardError
      rescue => e
        user = ::User.find_by(email: model.depositor) if model.depositor

        if user
          Hyrax::MessengerService.deliver(::User.audit_user,
                                          user,
                                          action(model, e),
                                          "DOI failed to mint or update")
        end
        Raven.capture_exception(e)
        # Requeue if this is a datacite connection issue
        raise if e.is_a? Hyrax::DOI::DataCiteClient::Error
      end
      # rubocop:enable Style/RescueStandardError

      def action(model, e)
        "DOI update filed for <a href='#{polymorphic_url(model)}'>#{model.title.first}</a>. Datacite said '#{e.message}'"
      end
    end
  end
end
