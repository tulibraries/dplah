require 'rails_helper'

RSpec.describe "OaiRecs", :type => :request do
  describe "GET /oai_recs" do
    it "works! (now write some real specs)" do
      get oai_recs_path
      expect(response).to have_http_status(200)
    end
  end
end
