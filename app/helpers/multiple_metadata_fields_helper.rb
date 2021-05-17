# TODO ~alignment: Bring over remaining methods from BL
module MultipleMetadataFieldsHelper
  def contains_full_url_path?(url)
    get_uri = URI.parse(url)
    if get_uri&.host && get_uri&.path
      true
    end
  end

  def match_key_to_url(key)
    hash_map = {"ror" => "https://ror.org/", "grid" => 'https://grid.ac/institutes/',
      "wikidata" => 'https://www.wikidata.org/entity/'
    }.with_indifferent_access
    hash_map[key]
  end

  def render_isni_or_orcid_url(id, type)
    id = id.strip.chomp('/').split('/').last
    new_id = id.delete('\n').delete('\t').gsub(/[^a-z0-9X]/, '')
    uri = URI.parse(new_id)
    if (uri.scheme.present? &&  uri.host.present?)
      domain = uri
      domain.to_s
    elsif (uri.scheme.present? == false && uri.path.present?)
      split_path(uri, type)
    elsif (uri.scheme.present? == false && uri.host.present? == false)
      create_isni_and_orcid_url(new_id, type)
    end
  end

  #The uri looks like  `#<URI::Generic orcid.org/0000-0002-1825-0097>` hence the need to split_path;
  # `split_domain_from_path` returns `["orcid.org", "0000-0002-1825-0097"]`
  # get_type is subsctracting a sub array from the main array eg (["orcid", "org"] - ["org"]) and returns ["orcid"]
  def split_path(uri, type)
    split_domain_from_path = uri.path.split('/')
    if split_domain_from_path.length == 1
      id = split_domain_from_path.join('')
      create_isni_and_orcid_url(id, type)
    else
      get_host = split_domain_from_path.shift
      split_host = get_host.split('.')
      get_type = (split_host - ['org']).join('')
      get_id = split_domain_from_path.join('')
      create_isni_and_orcid_url(get_id, get_type)
    end
  end

  def create_isni_and_orcid_url(id, type)
    if type == 'orcid'
      host = URI('https://orcid.org/')
      host.path = "/#{id}"
      host.to_s
    elsif type == "isni"
      host = URI('http://www.isni.org')
      host.path = "/isni/#{id}"
      host.to_s
    end
  end

  #Here we are checking in the works and search result page if the hash_keys for json fields
  # include values for either isni or orcid before displaying parenthesis
  def display_paren?(hash_keys, valid_keys)
    (hash_keys & valid_keys).any?
  end

  #Here we are checking in the works and search result page if the hash_keys for json fields
  # include a subset that is an array that includes either isni or orcid alongside contributor type before displaying a comma
  def display_comma?(hash_keys, valid_keys)
    all_keys_set = hash_keys.to_set
    if (valid_keys == ["contributor_type", "contributor_orcid", "contributor_isni"])
      keys_with_orcid_id = valid_keys.take(2)
      keys_with_isni_id = [valid_keys.first, valid_keys.last]
      array_with_orcid_id_set = keys_with_orcid_id.to_set
      array_with_isni_id_set = keys_with_isni_id.to_set
      array_with_orcid_id_set.subset? all_keys_set or array_with_isni_id_set.subset? all_keys_set
    else
      needed_keys_set = valid_keys.to_set
      needed_keys_set.subset? all_keys_set
    end
  end

  def add_image_space?(hash_keys)
    get_name = get_field_name(hash_keys)
    desired_fields = ["#{get_name}_orcid", "#{get_name}_isni"]
    desired_fields.to_set.subset? hash_keys.to_set
  end

  def get_field_name(hash_keys)
    if hash_keys.present?
      first_key = hash_keys.first
      first_key.split('_').first
    end
  end

  def get_model(presenter_record, model_class, field, multipart_sort_field_name = nil)
    #model ||= model_class.constantize.new

    #If the value of the first is record is nil return the model
    #@value =   get_json_data || model
    @value =  presenter_record.first

    if valid_json?(@value)
      array_of_hash ||= JSON.parse(presenter_record.first)
      return  [model.attributes] if (array_of_hash.first.class == String  || array_of_hash.first.nil? )

      #return sort_hash(array_of_hash, multipart_sort_field_name) if multipart_sort_field_name
      return sort_hash(array_of_hash, multipart_sort_field_name) if multipart_sort_field_name

      array_of_hash
    end
  end

  #leave it as a public method because it used in other files
  # return false if json == String
  def valid_json?(data)
    !!JSON.parse(data)  if data.class == String
    rescue JSON::ParserError
      false
  end

  private

  def sort_hash(array_of_hash, key)
    #return array_of_hash if array_of_hash.class != Array

    if (key.present? && array_of_hash.first.class == Hash)
      #allows the sort to function even if the value of a hash is nil
      array_of_hash.sort_by{ |hash| hash[key].to_i}
    end
  end

  def display_data_with_comma_separated(creator_hash, display_order)
    display_order.map { |ele| creator_hash[ele].presence }.compact.join(', ')
  end
end
