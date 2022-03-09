# frozen_string_literal: true

module AccountsHelper
  def host_for(sub_domain)
    default_host = ENV.fetch('HYKU_DEFAULT_HOST', "%<tenant>s.#{Account.admin_host}")
    default_host.gsub('%<tenant>s', sub_domain)
  end

  def full_search_url
    "//#{host_for('search')}/catalog"
  end
end
