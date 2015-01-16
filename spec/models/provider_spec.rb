require 'rails_helper'

RSpec.describe Provider, :type => :model do

  context "endpoint_url validation" do
    it "is valid" do
      provider = Provider.new(
        name: "MyName",
        description: "MyDescription",
        endpoint_url: "http://validurl.com",
        metadata_prefix: "MyPrefix",
        set: "MySet"
      ) 
      expect(provider).to be_valid
    end

    it "is not valid" do
      provider = Provider.new(
        name: "MyName",
        description: "MyDescription",
        endpoint_url: "InvalidURL",
        metadata_prefix: "MyPrefix",
        set: "MySet"
      ) 
      expect(provider).to_not be_valid
    end
  end
end
