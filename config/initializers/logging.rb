Rails.application.configure do
if ENV['LOGRAGE'].present? && ENV['LOGRAGE'] == "true"
  config.lograge.enabled = true
end
end
