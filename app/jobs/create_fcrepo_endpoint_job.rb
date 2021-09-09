# frozen_string_literal: true

class CreateFcrepoEndpointJob < ApplicationJob
  non_tenant_job

  def perform(account)
    return NilFcrepoEndpoint.new if account.is_shared_search_enabled?

    name = account.tenant.parameterize

    account.create_fcrepo_endpoint(base_path: "/#{name}")
  end
end
