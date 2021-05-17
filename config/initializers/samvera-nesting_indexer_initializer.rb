# rubocop:disable Naming/FileName
require 'samvera/nesting_indexer'
require 'hyrax/repository_reindexer'
# rubocop:enable Naming/FileName

# OVERRIDE: Hyrax 2.9 to add logger and not stop on failure

Samvera::NestingIndexer.configure do |config|
  config.logger = ActiveSupport::Logger.new(Rails.root.join('log', 'indexing.log'))
  config.stop_on_failure = false
  # How many layers of nesting are allowed for collections
  # For maximum_nesting_depth of 3 the following will raise an exception
  # C1 <- C2 <- C3 <- W1
  config.maximum_nesting_depth = 5
  config.adapter = Hyrax::Adapters::NestingIndexAdapter
  config.solr_field_name_for_storing_parent_ids = Solrizer.solr_name('nesting_collection__parent_ids', :symbol)
  config.solr_field_name_for_storing_ancestors =  Solrizer.solr_name('nesting_collection__ancestors', :symbol)
  config.solr_field_name_for_storing_pathnames =  Solrizer.solr_name('nesting_collection__pathnames', :symbol)
  config.solr_field_name_for_deepest_nested_depth = 'nesting_collection__deepest_nested_depth_isi'
end
