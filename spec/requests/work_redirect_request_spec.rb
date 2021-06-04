require 'rails_helper'

RSpec.describe "WorkRedirects", type: :request, singletenant: true do

  describe "GET /show" do
    let(:work) {FactoryBot.create(:generic_work)}

    it "redirects for /work" do
      get "/work/#{work.id}"
      expect(response).to have_http_status(:redirect)
    end

    it "redirects for /work/nc" do
      get "/work/#{work.id}"
      expect(response).to have_http_status(:redirect)
    end

    it "redirects for /work/sc" do
      get "/work/#{work.id}"
      expect(response).to have_http_status(:redirect)
    end

  end

end
