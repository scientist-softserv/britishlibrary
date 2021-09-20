# frozen_string_literal: true

module AccountsHelper
  def host_for(sub_domain)
    default_host = ENV.fetch('HYKU_DEFAULT_HOST', "%{tenant}.#{Account.admin_host}")
    default_host.gsub('%{tenant}', sub_domain)
  end
end
