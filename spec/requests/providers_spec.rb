require 'rails_helper'

RSpec.describe "Providers", :type => :request do
  describe "GET /providers" do
    let (:success) { 200 }
    let (:found) { 302 }
    it "works! (now write some real specs)" do
      get providers_path
      expect(response.status).to be(found)
    end
  end
end
