# frozen_string_literal: true

# Copied from Hyrax v2.9.0 to add home_text to permitted_params - Adding themes
module Hyrax
  class ContentBlocksController < ApplicationController
    # begin inject IrusAnalytics::InjectControllerHooksGenerator: include IrusAnalytics controller behavior
    include IrusAnalytics::Controller::AnalyticsBehaviour
    # end inject IrusAnalytics::InjectControllerHooksGenerator: include IrusAnalytics controller behavior
    # begin inject IrusAnalytics::InjectControllerHooksGenerator: IrusAnalytics after action
    after_action :send_irus_analytics_investigation, only: [:show]
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





    load_and_authorize_resource
    with_themed_layout 'dashboard'

    def edit
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb t(:'hyrax.admin.sidebar.configuration'), '#'
      add_breadcrumb t(:'hyrax.admin.sidebar.content_blocks'), hyrax.edit_content_blocks_path
    end

    def update
      respond_to do |format|
        if @content_block.update(value: update_value_from_params)
          format.html { redirect_to hyrax.edit_content_blocks_path, notice: t(:'hyrax.content_blocks.updated') }
        else
          format.html { render :edit }
        end
      end
    end

    private

      # override hyrax v2.9.0 added the home_text content block to permitted_params - Adding Themes
      def permitted_params
        params.require(:content_block).permit(:marketing,
                                              :announcement,
                                              :home_text,
                                              :researcher)
      end

      # When a request comes to the controller, it will be for one and
      # only one of the content blocks. Params always looks like:
      #   {'about_page' => 'Here is an awesome about page!'}
      # So reach into permitted params and pull out the first value.
      def update_value_from_params
        permitted_params.values.first
      end
  end
end
