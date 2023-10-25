Hyrax::Collections::PermissionsService.class_eval do 

  # Override Hyrax 2.9.6 to use a post request and avoid Long URI errors from Solr
  def self.filter_source(source_type:, ids:)
    return [] if ids.empty?
    id_clause = "{!terms f=id}#{ids.join(',')}"
    query = case source_type
            when 'admin_set'
              "_query_:\"{!raw f=has_model_ssim}AdminSet\""
            when 'collection'
              "_query_:\"{!raw f=has_model_ssim}Collection\""
            end
    query += " AND #{id_clause}"
    query(query, fl: 'id', rows: ids.count).map { |hit| hit['id'] }
  end
  private_class_method :filter_source

  # Query solr using POST so that the query doesn't get too large for a URI
  def self.query(query, args = {})
    args[:q] = query
    args[:qt] = 'standard'
    conn = ActiveFedora::SolrService.instance.conn
    result = conn.post('select', data: args)
    result.fetch('response').fetch('docs')
  end

end
