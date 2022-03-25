# frozen_string_literal: true

module AccountsHelper
  def host_for(sub_domain)
    # rubocop:disable Style/FormatStringToken
    default_host = ENV.fetch('HYKU_DEFAULT_HOST', "%{tenant}.#{Account.admin_host}")
    default_host.gsub('%{tenant}', sub_domain)
    # rubocop:enable Style/FormatStringToken
  end

  def full_search_url
    main_app.search_catalog_path
  end
end
