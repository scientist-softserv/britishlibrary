# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include HykuHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, prepend: true

  force_ssl if: :ssl_configured?

  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller

  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'

  helper_method :current_account, :admin_host?, :home_page_theme, :show_page_theme, :search_results_theme, :gtm_code
  before_action :authenticate_if_needed
  before_action :require_active_account!, if: :multitenant?
  before_action :set_account_specific_connections!
  before_action :elevate_single_tenant!, if: :singletenant?
  skip_after_action :discard_flash_if_xhr
  # add around action to load theme show page views
  around_action :inject_theme_views, except: :delete # rubocop:disable Rails/LexicallyScopedActionFilter

  rescue_from Apartment::TenantNotFound do
    raise ActionController::RoutingError, 'Not Found'
  end

  protected

    def is_hidden
      current_account.persisted? && !current_account.is_public?
    end

    def is_api_or_pdf
      request.format.to_s.match('json') ||
        params[:print] ||
        request.path.include?('api') ||
        request.path.include?('pdf')
    end

    def is_staging
      ['staging'].include?(Rails.env)
    end

    ##
    # Extra authentication for palni-palci during development phase
    def authenticate_if_needed
      # Disable this extra authentication in test mode
      return true if Rails.env.test?
      if (is_hidden || is_staging) && !is_api_or_pdf
        authenticate_or_request_with_http_basic do |username, password|
          username == ENV.fetch("HYKU_DEMO_USER", "bl_demo_user") && password == ENV.fetch("HYKU_DEMO_PASSWORD", "resu_omed_lb")
        end
      end
    end

    def super_and_current_users
      users = Role.find_by(name: 'superadmin')&.users.to_a
      users << current_user if current_user && !users.include?(current_user)
      users
    end

  #   def redirect_if_search
  #     redirect_to "//#{Account.admin_host}" if current_account.search_only
  #   end

  private

    def require_active_account!
      return if singletenant?
      return if devise_controller?
      raise Apartment::TenantNotFound, "No tenant for #{request.host}" unless current_account.persisted?
    end

    def set_account_specific_connections!
      current_account&.switch!
    end

    def multitenant?
      @multitenant ||= ActiveModel::Type::Boolean.new.cast(ENV.fetch('HYKU_MULTITENANT', false))
    end

    def singletenant?
      !multitenant?
    end

    def elevate_single_tenant!
      AccountElevator.switch!(current_account.cname) if current_account && root_host?
    end

    def root_host?
      Account.canonical_cname(request.host) == Account.root_host
    end

    def admin_host?
      return false if singletenant?
      Account.canonical_cname(request.host) == Account.admin_host
    end

    def current_account
      @current_account ||= Account.from_request(request)
      @current_account ||= if multitenant?
                             Account.new do |a|
                               a.build_solr_endpoint
                               a.build_fcrepo_endpoint
                               a.build_redis_endpoint
                             end
                           else
                             Account.single_tenant_default
                           end
    end

    # Find themes set on Site model, or return default
    def home_page_theme
      current_account.sites&.first&.home_theme || 'default_home'
    end

    def show_page_theme
      current_account.sites&.first&.show_theme || 'default_show'
    end

    def search_results_theme
      current_account.sites&.first&.search_theme || 'list_view'
    end

    # Add context information to the lograge entries
    def append_info_to_payload(payload)
      super
      payload[:request_id] = request.uuid
      payload[:user_id] = current_user.id if current_user
      payload[:account_id] = current_account.cname if current_account
    end

    def ssl_configured?
      ActiveRecord::Type::Boolean.new.cast(current_account.ssl_configured)
    end

    def gtm_code
      admin_host? ? 'GTM-KXSRB56' : current_account.settings['gtm_id']
    end

    # added to prepend the theme views into the view_paths. this method was originally being called in catalog_controller works_controller_behavior, and homepage_controller and it has been moved here to dry everthing up.
    def inject_theme_views
      original_paths = view_paths
      if show_page_theme && show_page_theme != "default_show"
        show_theme_view_path = Rails.root.join("app", "views", "themes", show_page_theme.to_s)
        prepend_view_path(show_theme_view_path)
      end

      if home_page_theme && home_page_theme != 'default_home'
        home_theme_view_path = Rails.root.join('app', 'views', "themes", home_page_theme.to_s)
        prepend_view_path(home_theme_view_path)
      end

      yield

      view_paths = original_paths # rubocop:disable Lint/UselessAssignment
    end
end
