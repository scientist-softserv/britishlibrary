# Overrides Hyrax 2.9.6 
# Allow users to add other's works as child works
Hyrax::My::FindWorksSearchBuilder.default_processor_chain -= [:show_only_resources_deposited_by_current_user]
