require 'rails_helper'

RSpec.describe "Records", :type => :request do
  describe "GET /records" do
    it "works! (now write some real specs)" do
      get records_path
      expect(response.status).to be(200)
    end
  end
end
