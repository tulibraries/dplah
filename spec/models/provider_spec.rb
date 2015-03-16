require 'rails_helper'

RSpec.describe Provider, :type => :model do

  let(:valid_url) { "http://validurl.com" }
  let(:default_metadata_prefix) { "oai_dc" }
  let(:default_interval) { 1.day }

  context "endpoint_url validation" do
    it "is valid" do
      provider = Provider.new(endpoint_url: valid_url) 
      expect(provider).to be_valid
    end

    it "is not valid" do
      provider = Provider.new(endpoint_url: "InvalidURL") 
      expect(provider).to_not be_valid
    end
  end

  context "initialized attributes" do
  
    let(:p) { FactoryGirl.build(:provider) }
    let!(:provider) {
      Provider.new(
        name: p.name,
        description: p.description,
        endpoint_url: p.endpoint_url,
        metadata_prefix: p.metadata_prefix,
        set: p.set,
        contributing_institution: p.contributing_institution
      ) 
    }


    it "specifies the name" do
      expect(provider.name).to eq(p.name)
    end

    it "specifies the description" do
      expect(provider.description).to eq(p.description)
    end

    it "specifies the endpoint url" do
      expect(provider.endpoint_url).to eq(p.endpoint_url)
    end

    it "specifies the metadata_prefix" do
      expect(provider.metadata_prefix).to eq(p.metadata_prefix)
    end

    it "specifies the set" do
      expect(provider.set).to eq(p.set)
    end

    it "specifies the contributing_institution" do
      expect(provider.contributing_institution).to eq(p.contributing_institution)
    end
  end

  context "uninitialized attributes" do

    let!(:provider) { Provider.new(endpoint_url: valid_url) }

    it "does not specify the name" do
      expect(provider.name).to eq(valid_url)
    end

    it "does not specify the set" do
      expect(provider.set).to be_nil
    end

    it "does not specify the metadata_prefix" do
      expect(provider.metadata_prefix).to eq(default_metadata_prefix)
    end

    it "does not specify the contributing institution" do
      expect(provider.contributing_institution).to eq("")
    end

    it "does not specify the interval" do
      expect(provider.interval).to eq(default_interval)
    end
  end

  describe "client method" do
    let(:client) { FactoryGirl.build(:provider).client }

    it "gets a client object" do
      expect(client.class.to_s).to eq("OAI::Client")
      expect(client.instance_variable_get(:@parser)).to eq("libxml")
    end

  end

  describe "granularity" do
    it "is a pending example"
  end

  describe "each_record" do
    it "is a pending example"
  end

  describe "next_harvest_at" do
    it "is a pending example"
  end

  describe "non-default interval" do
    it "is a pending example"
  end

  describe "consumed_at" do
    it "is a pending example"
  end

# [TODO] Candidate for deprecation
#  describe "record_class" do
#    it "returns the default record class name" do
#      pending "As implemented, returns nil value. TBD: Verify desired behavior"
#      provider = FactoryGirl.build(:provider)
#      expect(provider.record_class).to eq("#{default_metadata_prefix}_document")
#    end
#  end
#
#	it "default_record_class_name" do
#    provider = FactoryGirl.build(:provider)
#    expect(provider.default_record_class_name).to eq("#{default_metadata_prefix}_document")
#	end
#
#	describe "record_class=" do
#		it "is a pending example"
#	end
end
