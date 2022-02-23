module Hyrax
  module AbilityDecorator
    def featured_collection_abilities
      can [:create, :destroy, :update], FeaturedCollection if admin?
    end
  end
end

Hyrax::Ability.prepend(Hyrax::AbilityDecorator)
