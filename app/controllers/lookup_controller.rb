class LookupController < ApplicationController
  # TODO: do we need these other items from the poorly named AvailableUbiquityTitlesController?
  # def check
  #   title = params["title"]
  #   alternative_title = params["alternative_title"].reject(&:blank?)
  #   both_title = [ params["title"] ] + params["alternative_title"].to_a
  #   returned_titles = Ubiquity::TitleChecker.new(title, alternative_title, params["model_class"]).get_records
  #   if returned_titles.present?
  #     render json: { "data": 'true', "message": title_unavailable_message_based_on_count(returned_titles), "title_list": returned_titles.join(', ')}
  #   else
  #     render json: { "data": 'false', "message": title_available_message_based_on_count(both_title) }
  #   end
  # end

  # def call_datasite
  #   url = params["url"]
  #   datacite = DataciteClient.new(url).fetch_record
  #   render json: { 'data': datacite.data }
  # end

  def funder
    response_data = FunderApiData.new(params['funder_id']).fetch_record
    render json: { 'data': response_data }
  end
end

private

# def title_unavailable_message_based_on_count(record_ary)
#   if record_ary.count > 1
#     'The Following Titles are being used: '
#   else
#     'This Title is being used: '
#   end
# end

# def title_available_message_based_on_count(record_ary)
#   record_ary.reject!(&:blank?)
#   if record_ary.count > 1
#     'The Titles are available'
#   else
#     'This Title is available'
#   end
# end
