# frozen_string_literal: true

config = YAML.safe_load(ERB.new(IO.read(Rails.root + 'config' + 'redis.yml')).result)[Rails.env].with_indifferent_access
Resque.redis = config.merge(thread_safe: true)