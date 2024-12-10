# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.5'

# pre release versions for index fixes
gem 'ldp', '>= 1.0.3'
gem 'samvera-nesting_indexer', git: 'https://github.com/samvera-labs/samvera-nesting_indexer.git', branch: 'skip_failure_option'
gem 'activerecord-nulldb-adapter'
# Use sqlite3 as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 4.3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'active-fedora', '>= 11.1.4'
gem 'flutie'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
gem 'browse-everything', '~> 1.1.2'
gem 'irus_analytics', git: 'https://github.com/notch8/irus_analytics', branch: :active_job_edition

group :development, :test do
  gem 'pry-byebug'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  gem 'i18n-debug', require: false
  gem 'i18n-tasks'
  gem 'rspec'
  gem 'rspec-rails', '>= 3.6.0'

  gem 'simplecov', require: false

  gem 'fcrepo_wrapper', '~> 0.4'
  gem 'solr_wrapper', '~> 2.0'

  gem 'rubocop', '~> 0.50', '<= 0.52.1'
  gem 'rubocop-rspec', '~> 1.22', '<= 1.22.2'
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot', '~> 1.0'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'launchy'
  # rack-test >= 0.71 does not work with older Capybara versions (< 2.17). See #214 for more details
  gem 'rack-test', '0.7.0'
  gem 'rails-controller-testing'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-its'
  gem 'rspec-retry'
  gem 'rspec_junit_formatter'
  gem 'selenium-webdriver', '3.142.7'
  gem 'shoulda-matchers', '~> 4.0'
  gem 'webdrivers', '~> 4.0'
  gem 'webmock'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '>= 3.3.0'

  gem 'listen', '>= 3.0.5', '< 3.2'
  # Pronto adds comments to MRs in gitlab when rubocop offenses are made.
  gem 'pronto'
  gem 'pronto-brakeman', require: false
  gem 'pronto-flay', require: false
  gem 'pronto-rails_best_practices', require: false
  gem 'pronto-rails_schema', require: false
  gem 'pronto-rubocop', require: false
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'easy_translate'
  gem 'scss_lint', require: false
  gem 'spring', '~> 1.7'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'
  # gem 'xray-rails' # when using this gem, know that sidekiq will not work
end

# Bulkrax :: Upgrading passed this point might cause issues, for now we've made a
#            branch off v5.3.1 that includes `DownloadCloudFileJob` work.
#gem 'bulkrax', git: 'https://github.com/samvera/bulkrax', branch: '5.3.1-british_library'
gem 'bulkrax', git: 'https://github.com/samvera/bulkrax', tag: 'v8.0.0'


gem 'blacklight', '~> 6.7'
gem 'blacklight_oai_provider', '~> 6.1', '>= 6.1.1'

# Updating Hyrax to a branch that brings in iiif_manifest v1.3.1
gem 'hyrax', git: 'https://github.com/samvera/hyrax.git', branch: 'hyrax-iiif-manifest-upgrade'

gem 'rsolr', '~> 2.0'

gem 'devise'
gem 'devise-guests', '~> 0.3'
gem 'devise-i18n'
gem 'devise_invitable', '~> 1.6'

gem 'apartment'
gem 'is_it_working'
gem 'rolify'

gem 'flipflop', '~> 2.3'
gem 'lograge'

gem 'hyrax-doi', git: 'https://github.com/samvera-labs/hyrax-doi.git', branch: 'main'
gem 'hyrax-iiif_av', git: 'https://github.com/samvera-labs/hyrax-iiif_av.git', ref: '6273f90'
gem 'httparty'
gem 'mods', '~> 2.4'

group :aws, :test do
  gem 'carrierwave-aws', '~> 1.3'
end

group :aws do
  gem 'active_elastic_job', git: 'https://github.com/tawan/active-elastic-job.git'
  gem 'aws-sdk-sqs'
end

gem 'bootstrap-datepicker-rails'
gem "cocoon"
gem 'codemirror-rails'
gem 'parser', '~> 2.5.3'
gem 'rdf', '~> 3.1.15' # rdf 3.2.0 removed SerializedTransaction which ldp requires
gem 'riiif', '~> 1.1'
gem 'secure_headers'
gem 'rubyzip', '~> 2.3.2'
# Sentry-raven for error handling
gem "sentry-raven"
gem 'sidekiq'
gem 'tether-rails'
gem 'validate_url'
gem 'hyrax-v2_graph_indexer', "~> 0.5", git: 'https://github.com/scientist-softserv/hyrax-v2_graph_indexer.git', ref: '53b0a2d28868af25d306bc361634439c008892ac'
gem 'iiif_print', git: 'https://github.com/scientist-softserv/iiif_print.git'
