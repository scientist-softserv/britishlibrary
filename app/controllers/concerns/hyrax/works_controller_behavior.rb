# frozen_string_literal: true

# OVERRIDE: British Libraries override to Hyrax v.2.9.5 so that a new work defaults to a "public" visibility
# COPIED FROM HYRAX 2.9.0 to add inject_show_theme_views - Hyku theming
# OVERRIDE: Hyrax 2.9.0 move inject_show_theme_views to application_controller so themes apply everywhere. in application controller the method is called inject_theme_views
require "iiif_manifest"
require "hyrax/doi/errors"

module Hyrax
  module WorksControllerBehavior # rubocop:disable Metrics/ModuleLength
    extend ActiveSupport::Concern
    include Blacklight::Base
    include Blacklight::AccessControls::Catalog
    included do
      with_themed_layout :decide_layout
      copy_blacklight_config_from(::CatalogController)
      rescue_from Hyrax::DOI::NotFoundError, with: :error_doi_not_found

      class_attribute :_curation_concern_type,
                      :show_presenter,
                      :work_form_service,
                      :search_builder_class,
                      :iiif_manifest_builder
      self.show_presenter = Hyrax::WorkShowPresenter
      self.work_form_service = Hyrax::WorkFormService
      self.search_builder_class = WorkSearchBuilder
      self.iiif_manifest_builder = (Flipflop.cache_work_iiif_manifest? ? Hyrax::CachingIiifManifestBuilder.new : Hyrax::ManifestBuilderService.new)
      attr_accessor :curation_concern
      helper_method :curation_concern, :contextual_path

      rescue_from WorkflowAuthorizationException, with: :render_unavailable
    end

    class_methods do
      def curation_concern_type=(curation_concern_type)
        load_and_authorize_resource class: curation_concern_type,
                                    instance_name: :curation_concern,
                                    except: %i[show file_manager inspect_work manifest]

        # Load the fedora resource to get the etag.
        # No need to authorize for the file manager, because it does authorization via the presenter.
        load_resource class: curation_concern_type, instance_name: :curation_concern, only: :file_manager

        self._curation_concern_type = curation_concern_type
        # We don't want the breadcrumb action to occur until after the concern has
        # been loaded and authorized
        before_action :save_permissions, only: :update # rubocop:disable Rails/LexicallyScopedActionFilter
      end

      def curation_concern_type
        _curation_concern_type
      end

      def cancan_resource_class
        Hyrax::ControllerResource
      end
    end

    def new
      set_doi_data if params["doi"].present?
      # TODO: move these lines to the work form builder in Hyrax
      curation_concern.depositor = current_user.user_key
      curation_concern.admin_set_id = admin_set_id_for_new
      # NOTE: British Libraries override to Hyrax v.2.9.5
      # so that a new work defaults to a "public" visibility
      curation_concern.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      build_form
    end

    def create
      if actor.create(actor_environment)
        after_create_response
      else
        respond_to do |wants|
          wants.html do
            build_form
            render "new", status: :unprocessable_entity
          end
          wants.json do
            render_json_response(
              response_type: :unprocessable_entity,
              options: { errors: curation_concern.errors }
            )
          end
        end
      end
    end

    # Finds a solr document matching the id and sets @presenter
    # @raise CanCan::AccessDenied if the document is not found or the user doesn't have access to it.
    def show
      @user_collections = user_collections

      respond_to do |wants|
        wants.html { presenter && parent_presenter }
        wants.json do
          # load and authorize @curation_concern manually because it's skipped for html
          @curation_concern = _curation_concern_type.find(params[:id]) unless curation_concern
          authorize! :show, @curation_concern
          render :show, status: :ok
        end
        additional_response_formats(wants)
        wants.ttl do
          render body: presenter.export_as_ttl, content_type: "text/turtle"
        end
        wants.jsonld do
          render body: presenter.export_as_jsonld, content_type: "application/ld+json"
        end
        wants.nt do
          render body: presenter.export_as_nt, content_type: "application/n-triples"
        end
      end
    end

    def edit
      set_doi_data if params["doi"].present?
      build_form
    end

    def update
      if actor.update(actor_environment)
        after_update_response
      else
        respond_to do |wants|
          wants.html do
            build_form
            render "edit", status: :unprocessable_entity
          end
          wants.json do
            render_json_response(
              response_type: :unprocessable_entity,
              options: { errors: curation_concern.errors }
            )
          end
        end
      end
    end

    def destroy
      title = curation_concern.to_s
      env = Actors::Environment.new(curation_concern, current_ability, {})
      return unless actor.destroy(env)
      Hyrax.config.callback.run(:after_destroy, curation_concern.id, current_user)
      after_destroy_response(title)
    end

    def file_manager
      @form = Forms::FileManagerForm.new(curation_concern, current_ability)
    end

    def inspect_work
      raise Hydra::AccessDenied unless current_ability.admin?
      presenter
    end

    def manifest
      headers["Access-Control-Allow-Origin"] = "*"

      json = json_manifest

      respond_to do |wants|
        wants.json { render json: json }
        wants.html { render json: json }
      end
    end

    def json_manifest
      iiif_manifest_builder.manifest_for(presenter: iiif_manifest_presenter)
    end

    private

      def error_doi_not_found
        respond_to do |with|
          with.all { render plain: "DOI not found.", status: 404 }
          with
        end
      end

      def set_doi_data
        return if params["doi"].blank?

        begin
          @work_attributes = hyrax_work_from_doi(params["doi"])
          curation_concern.attributes = @work_attributes
          flash_keys = @work_attributes.reject { |_k, v| v.blank? }.keys.map { |k| t("simple_form.labels.defaults.#{k}", default: k.humanize) }.uniq
          flash[:notice] = ["The following fields were auto-populated:", flash_keys.to_sentence]
        rescue StandardError => e
          Rails.logger.info(e.message)
          raise if Rails.env.development?
          raise Hyrax::DOI::NotFoundError
        end
      end

      def hyrax_work_from_doi(doi)
        # TODO: generalize this
        meta = Bolognese::Metadata.new(input: doi,
                                       from: "datacite",
                                       sandbox: false)
        if meta.blank? || meta.doi.blank? || meta.state == "not_found"
          meta = Bolognese::Metadata.new(input: doi,
                                         from: "crossref",
                                         sandbox: false)
        end
        if meta.blank? || meta.doi.blank? || meta.state == "not_found"
          meta = Bolognese::Metadata.new(input: doi,
                                         from: "datacite",
                                         sandbox: true)
        end
        # Check that a record was actually loaded
        raise Hyrax::DOI::NotFoundError, "DOI (#{doi}) could not be found." if meta.blank? || meta.doi.blank?
        meta.types["hyrax"] = curation_concern.class.to_s
        meta.hyrax_work
      end

      def iiif_manifest_builder
        self.class.iiif_manifest_builder
      end

      def iiif_manifest_presenter
        IiifManifestPresenter.new(curation_concern_from_search_results).tap do |p|
          p.hostname = request.hostname
          p.ability = current_ability
        end
      end

      def user_collections
        collections_service.search_results(:deposit)
      end

      def collections_service
        Hyrax::CollectionsService.new(self)
      end

      def admin_set_id_for_new
        # admin_set_id is required on the client, otherwise simple_form renders a blank option.
        # however it isn't a required field for someone to submit via json.
        # Set the default admin set if it exists; otherwise, set to first admin_set they have access to.
        admin_sets = Hyrax::AdminSetService.new(self).search_results(:deposit)
        return nil if admin_sets.blank? # shouldn't happen
        return AdminSet::DEFAULT_ID if admin_sets.map(&:id).include?(AdminSet::DEFAULT_ID)
        admin_sets.first.id
      end

      def build_form
        @form = work_form_service.build(curation_concern, current_ability, self)
      end

      def actor
        @actor ||= Hyrax::CurationConcern.actor
      end

      def presenter
        @presenter ||= show_presenter.new(curation_concern_from_search_results, current_ability, request)
      end

      def parent_presenter
        return @parent_presenter unless params[:parent_id]

        @parent_presenter ||=
          show_presenter.new(search_result_document(id: params[:parent_id]), current_ability, request)
      end

      # Include 'hyrax/base' in the search path for views, while prefering
      # our local paths. Thus we are unable to just override `self.local_prefixes`
      def _prefixes
        @_prefixes ||= super + ["hyrax/base"]
      end

      def actor_environment
        Actors::Environment.new(curation_concern, current_ability, attributes_for_actor)
      end

      def hash_key_for_curation_concern
        _curation_concern_type.model_name.param_key
      end

      def contextual_path(presenter, parent_presenter)
        ::Hyrax::ContextualPath.new(presenter, parent_presenter).show
      end

      def curation_concern_from_search_results
        search_params = params
        search_params.delete :page
        search_result_document(search_params)
      end

      # Only returns unsuppressed documents the user has read access to
      def search_result_document(search_params)
        _, document_list = search_results(search_params)
        return document_list.first unless document_list.empty?
        document_not_found!
      end

      def document_not_found!
        doc = ::SolrDocument.find(params[:id])
        raise WorkflowAuthorizationException if doc.suppressed? && current_ability.can?(:read, doc)
        raise CanCan::AccessDenied.new(nil, :show)
      end

      def render_unavailable
        message = I18n.t("hyrax.workflow.unauthorized")
        respond_to do |wants|
          wants.html do
            unavailable_presenter
            flash[:notice] = message
            render "unavailable", status: :unauthorized
          end
          wants.json do
            render plain: message, status: :unauthorized
          end
          additional_response_formats(wants)
          wants.ttl do
            render plain: message, status: :unauthorized
          end
          wants.jsonld do
            render plain: message, status: :unauthorized
          end
          wants.nt do
            render plain: message, status: :unauthorized
          end
        end
      end

      def unavailable_presenter
        @presenter ||= show_presenter.new(::SolrDocument.find(params[:id]), current_ability, request)
      end

      def decide_layout
        layout = case action_name
                 when "show"
                   "1_column"
                 else
                   "dashboard"
                 end
        File.join(theme, layout)
      end

      # Add uploaded_files to the parameters received by the actor.
      def attributes_for_actor
        raw_params = params[hash_key_for_curation_concern]
        attributes = if raw_params
                       work_form_service.form_class(curation_concern).model_attributes(raw_params)
                     else
                       {}
                     end

        # If they selected a BrowseEverything file, but then clicked the
        # remove button, it will still show up in `selected_files`, but
        # it will no longer be in uploaded_files. By checking the
        # intersection, we get the files they added via BrowseEverything
        # that they have not removed from the upload widget.
        uploaded_files = params.fetch(:uploaded_files, [])
        selected_files = params.fetch(:selected_files, {}).values
        browse_everything_urls = uploaded_files &
                                 selected_files.map { |f| f[:url] }

        # we need the hash of files with url and file_name
        browse_everything_files = selected_files
                                  .select { |v| uploaded_files.include?(v[:url]) }
        attributes[:remote_files] = browse_everything_files
        # Strip out any BrowseEverthing files from the regular uploads.
        attributes[:uploaded_files] = uploaded_files -
                                      browse_everything_urls
        attributes
      end

      def after_create_response
        respond_to do |wants|
          wants.html do
            # Calling `#t` in a controller context does not mark _html keys as html_safe
            flash[:notice] = view_context.t(
              "hyrax.works.create.after_create_html",
              application_name: view_context.application_name
            )
            redirect_to [main_app, curation_concern]
          end
          wants.json { render :show, status: :created, location: polymorphic_path([main_app, curation_concern]) }
        end
      end

      def after_update_response
        if curation_concern.file_sets.present?
          return redirect_to hyrax.confirm_access_permission_path(curation_concern) if permissions_changed?
          return redirect_to main_app.confirm_hyrax_permission_path(curation_concern) if curation_concern.visibility_changed?
        end
        respond_to do |wants|
          wants.html do
            redirect_to [main_app, curation_concern],
                        notice: "Work \"#{curation_concern}\" successfully updated."
          end
          wants.json { render :show, status: :ok, location: polymorphic_path([main_app, curation_concern]) }
        end
      end

      def after_destroy_response(title)
        respond_to do |wants|
          wants.html { redirect_to my_works_path, notice: "Deleted #{title}" }
          wants.json { render_json_response(response_type: :deleted, message: "Deleted #{curation_concern.id}") }
        end
      end

      def additional_response_formats(format)
        format.endnote do
          send_data(presenter.solr_document.export_as_endnote,
                    type: "application/x-endnote-refer",
                    filename: presenter.solr_document.endnote_filename)
        end
      end

      def save_permissions
        @saved_permissions = curation_concern.permissions.map(&:to_hash)
      end

      def permissions_changed?
        @saved_permissions != curation_concern.permissions.map(&:to_hash)
      end
  end
end
