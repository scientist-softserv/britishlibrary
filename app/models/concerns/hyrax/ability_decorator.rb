module Hyrax
  module AbilityDecorator
    def self.ability_logic
      %i[admin_permissions
         curation_concerns_permissions
         operation_abilities
         add_to_collection
         user_abilities
         featured_work_abilities
         featured_collection_abilities
         editor_abilities
         stats_abilities
         citation_abilities
         proxy_deposit_abilities
         uploaded_file_abilities
         feature_abilities
         admin_set_abilities
         collection_abilities
         collection_type_abilities
         permission_template_abilities
         solr_document_abilities
         trophy_abilities]
    end

    def featured_collection_abilities
      can [:create, :destroy, :update], FeaturedCollection if admin?
    end
  end
end

Hyrax::Ability.prepend(Hyrax::AbilityDecorator)
