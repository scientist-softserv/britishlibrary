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
        doi = model.doi.presence || [model.original_doi]
        return if doi.blank?

        Hyrax::Identifier::Dispatcher
          .for(registrar.to_sym, **registrar_opts)
          .assign_for!(object: model, attribute: :doi )
      rescue Hyrax::DOI::DataCiteClient::Error => e
        user = ::User.find_by(email: model.depositor) if model.depositor

        if user
          Hyrax::MessengerService.deliver(::User.audit_user,
                                          user,
                                          action(model, e),
                                          "DOI failed to mint or update")
        end
        raise
      end

      def action(model, e)
        "DOI update filed for <a href='#{polymorphic_url(model)}'>#{model.title.first}</a>. Datacite said '#{e.message}'"
      end
    end
  end
end
