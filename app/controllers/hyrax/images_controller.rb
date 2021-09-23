# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  # Generated controller for Image
  class ImagesController < SharedBehaviorsController
    # begin inject IrusAnalytics::InjectControllerHooksGenerator: include IrusAnalytics controller behavior
    include IrusAnalytics::Controller::AnalyticsBehaviour
    # end inject IrusAnalytics::InjectControllerHooksGenerator: include IrusAnalytics controller behavior
    # begin inject IrusAnalytics::InjectControllerHooksGenerator: IrusAnalytics after action
    after_action :send_irus_analytics_investigation, only: [:show]
    # end inject IrusAnalytics::InjectControllerHooksGenerator: IrusAnalytics after action
    # begin inject IrusAnalytics::InjectControllerHooksGenerator: IrusAnalytics after action
    after_action :send_irus_analytics_request, only: [:zip_download]
    # end inject IrusAnalytics::InjectControllerHooksGenerator: IrusAnalytics after action

  public
    # begin inject IrusAnalytics::InjectControllerHooksGenerator: item_identifier_for_irus_analytics
    def item_identifier_for_irus_analytics
      # return the OAI identifier
      # http://www.openarchives.org/OAI/2.0/guidelines-oai-identifier.htm
      CatalogController.blacklight_config.oai[:provider][:record_prefix] + ":" + params[:id]
    end
    # end inject IrusAnalytics::InjectControllerHooksGenerator: item_identifier_for_irus_analytics
    # begin inject IrusAnalytics::InjectControllerHooksGenerator: skip_send_irus_analytics?
    def skip_send_irus_analytics?(usage_event_type)
      # return true to skip tracking, for example to skip curation_concerns.visibility == 'private'
      case usage_event_type
      when 'Investigation'
        false
      when 'Request'
        false
      end
    end
    # end inject IrusAnalytics::InjectControllerHooksGenerator: skip_send_irus_analytics?





    # Adds Hyrax behaviors to the controller.
    self.curation_concern_type = ::Image

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ImagePresenter
  end
end
