module Hyrax
  class SharedBehaviorsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include IrusAnalytics::Controller::AnalyticsBehaviour
    # use the investigation hook to track work_type views
    after_action :send_irus_analytics_investigation, only: [:show]

  public
    def item_identifier_for_irus_analytics
      # return the OAI identifier
      # http://www.openarchives.org/OAI/2.0/guidelines-oai-identifier.htm
      "#{CatalogController.blacklight_config.oai[:provider][:record_prefix].call(self)}:#{params[:id]}"
    end

    def skip_send_irus_analytics?(usage_event_type)
      # return true to skip tracking, for example to skip curation_concerns.visibility == 'private'
      case usage_event_type
      when 'Investigation'
        false
      when 'Request'
        false
      end
    end

    # TODO include Ubiquity::BreadcrumbOverride

    private
    # TODO understand notes/conversation feature
     #  def after_update_response
     #    notes_on_work if params[hash_key_for_curation_concern]['note'].present?
     #    download_stats = WorkDownloadStat.find_by(work_uid: presenter.solr_document.id)
     #    download_stats.update_attributes(title: presenter.solr_document.title.first) if download_stats
     #    super
     #  end

     #  def after_create_response
     #    notes_on_new_work if params[hash_key_for_curation_concern]['note'].present?
     #    super
     #  end

     #  def notes_on_work
     #    model = presenter.model
     #    work_id = presenter.solr_document.id
     #    create_notes(model, work_id)
     #  end

     #  # works being ingested cannot access a presenter like in 'notes_on_work'
     #  def notes_on_new_work
     #    work_gid = Sipity::Entity.last.proxy_for_global_id
     #    arr = work_gid.split('hyku/').last
     #    model = arr.split('/').first
     #    work_id = arr.split('/').last
     #    create_notes(model, work_id)
     #  end

     #  def create_notes(model, work_id)
     #    new_note = ::Ubiquity::CreateNoteOnWorkService.new(current_user,
     #                                                    params[hash_key_for_curation_concern]['note'],
     #                                                    model,
     #                                                    work_id)
     #    message_receipt = new_note.call
     #    new_conversation_subject(model, work_id, message_receipt)
     #  end

     # def new_conversation_subject(model, work_id, message_receipt)
     #    c_subject = model + '_' + work_id
     #    conversation = get_conversation(message_receipt)
     #    conversation.subject = c_subject
     #    conversation.save
     #  end

     #  #When we send a message by calling 'send_message' it returns a MailboxeR::Receipts object.
     #  #Since the receipt object belongs_to Mailboxer::Message, we can fetch the message through it
     #  #and then fetch conversation_id through the message
     #  def get_conversation(message_receipt)
     #    message = message_receipt.message
     #    message.conversation
     #  end

  end
end
