require "rails_helper"

RSpec.describe OaiRecsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/oai_recs").to route_to("oai_recs#index")
    end

    it "routes to #new" do
      expect(:get => "/oai_recs/new").to route_to("oai_recs#new")
    end

    it "routes to #show" do
      expect(:get => "/oai_recs/1").to route_to("oai_recs#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/oai_recs/1/edit").to route_to("oai_recs#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/oai_recs").to route_to("oai_recs#create")
    end

    it "routes to #update" do
      expect(:put => "/oai_recs/1").to route_to("oai_recs#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/oai_recs/1").to route_to("oai_recs#destroy", :id => "1")
    end

  end
end
