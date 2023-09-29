# frozen_string_literal: true

class Ability
  include Hydra::Ability
  include Hyrax::Ability

  self.ability_logic += %i[
    everyone_can_create_curation_concerns
    group_permissions
    superadmin_permissions
    featured_collection_abilities
  ]

  # Define any customized permissions here.
  def custom_permissions
    can [:create], Account
  end

  def admin_permissions
    return unless admin?
    return if superadmin?

    super
    can [:manage], [Site, Role, User]

    can [:read, :update], Account do |account|
      account == Site.account
    end
  end

  def group_permissions
    return unless admin?

    can :manage, Hyku::Group
  end

  def superadmin_permissions
    return unless superadmin?

    can :manage, :all
  end

  def superadmin?
    current_user.has_role? :superadmin
  end

  def featured_collection_abilities
    can [:create, :destroy, :update], FeaturedCollection if admin?
  end

  # Override from blacklight-access_controls-0.6.2 to define registered to include having a role on this tenant
  def user_groups
    return @user_groups if @user_groups

    @user_groups = default_user_groups
    @user_groups |= current_user.groups if current_user.respond_to? :groups
    @user_groups |= ['registered'] if !current_user.new_record? && current_user.roles.count.positive?
    @user_groups
  end

  # @see https://github.com/samvera-labs/bulkrax/pull/707
  def can_import_works?
    can_create_any_work?
  end

  # @see https://github.com/samvera-labs/bulkrax/pull/707
  def can_export_works?
    can_create_any_work?
  end

  # Overrides hyarx 2.9.6 to call a version of admin_set_with_deposit? that limits
  # the id string used in the solr query to 200 ids (see admin_set_with_deposit_limited?
#  def can_create_any_work?
#    Hyrax.config.curation_concerns.any? do |curation_concern_type|
#      can?(:create, curation_concern_type)
#    end && admin_set_with_deposit_limited?
#  end

  # If the ids string is too long then solr will bail so (until we are on hyrax3.x)
  # introduce an _entirely_ abitrary limit to the number of ids used in query
  # admin_Sets with depositos _should_ appear in the first 200 collections, but there
  # is a risk that this fix will mis-report whether a user can create a work in an admin set
  # The mis-report will be a false negative so will not admit users to any admin_sets
  # they shouldn't have access to, but may in extreme circumstances lock some out.
  # TODO upgrade hyrax used by hyku to version 3.x
  def admin_set_with_deposit?
    ids = Hyrax::PermissionTemplateAccess.for_user(ability: self,
                                                   access: ['deposit', 'manage'])
                                         .joins(:permission_template)
                                         .pluck(Arel.sql('DISTINCT source_id'))
    query = "_query_:\"{!raw f=has_model_ssim}AdminSet\" AND {!terms f=id}#{ids.join(',')}"
    solr_query(query).count.positive?
  end

  # Query solr using POST so that the query doesn't get too large for a URI
  def solr_query(query, args = {})
    args[:q] = query
    args[:qt] = 'standard'
    conn = ActiveFedora::SolrService.instance.conn
    result = conn.post('select', data: args)
    result.fetch('response').fetch('docs')
  end
end
