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

  # Override Hyrax 2.9.6 to use post with solr and avoid over long URI errors
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
