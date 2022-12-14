class FunderApiData
  attr_accessor :response

  def initialize(funder_id)
    url = "https://api.ror.org/organizations?query=" + funder_id
    @response = fetch_record_from_url(url)
  end

  def fetch_isni
    response_hash = response.parsed_response
    response_hash.dig("items").first["external_ids"].dig("ISNI")&.dig("all") if response_hash.dig("items").first["external_ids"].present?
  end

  def fetch_ror
    response_hash = response.parsed_response
    response_hash.dig("items").first.dig("id") if response_hash.dig("items").first.present?
  end

  def fetch_record
    if response.class == HTTParty::Response && response.dig("items").first
      { "funder_isni" => fetch_isni,
        "funder_ror" => fetch_ror }
    else
      { error: response }
    end
  end

  private

    def fetch_record_from_url(url)
      handle_client do
        HTTParty.get(url)
      end
    end

    def handle_client
      yield
    # rubocop:disable Lint/ShadowedException
    rescue URI::InvalidURIError, HTTParty::Error, Net::HTTPNotFound, NoMethodError, Net::OpenTimeout, StandardError => e
      # rubocop:enable Lint/ShadowedException
      "Api server error #{e.inspect}"
    end
end
