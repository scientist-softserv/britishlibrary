# frozen_string_literal: true

class DeleteOldGuestsJob < ApplicationJob
  non_tenant_job
  after_perform do |job|
    reenqueue
  end

  def perform
    User.where("guest = ? and updated_at < ?", true, Time.now - 7.days).each { |x| x.destroy}
  end

  private

  def reenqueue
    DeleteOldGuestsJob.set(wait_until: Date.tomorrow.midnight).perform_later
  end
end
