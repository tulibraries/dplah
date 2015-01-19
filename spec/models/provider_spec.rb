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
  
    let(:a_name) { "MyName" }
    let(:a_description) { "MyDescription" }
    let(:a_prefix) { "my-prefix" }
    let(:a_set) { "MySet" }
    let(:an_institution) { "MyInstitution" }

    let!(:provider) {
      Provider.new(
        name: a_name,
        description: a_description,
        endpoint_url: valid_url,
        metadata_prefix: a_prefix,
        set: a_set,
        contributing_institution: an_institution
      ) 
    }

    it "specifies the name" do
      expect(provider.name).to eq(a_name)
    end

    it "specifies the description" do
      expect(provider.description).to eq(a_description)
    end

    it "specifies the metadata_prefix" do
      expect(provider.metadata_prefix).to eq(a_prefix)
    end

    it "specifies the set" do
      expect(provider.set).to eq(a_set)
    end

    it "specifies the contributing_institution" do
      expect(provider.contributing_institution).to eq(an_institution)
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
    let(:provider) { Provider.new(endpoint_url: valid_url) }
    let(:client) { Provider.new(endpoint_url: valid_url).client }

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
    it "returns non-default interval" do
      provider = Provider.new(endpoint_url: valid_url)
      provider.instance_variable_set(:@interval, 7.days)
      provider.interval = 7.days
      expect(provider.instance_variable_get(:@interval)).to eq(7.days)
    end
  end

  describe "consumed_at" do
    it "is a pending example"
  end

  describe "record_class" do
    it "returns the default record class name" do
      provider = Provider.new(endpoint_url: valid_url)
      expect(provider.record_class).to eq("#{default_metadata_prefix}_document")
    end
  end

	it "default_record_class_name" do
    provider = Provider.new(endpoint_url: valid_url)
    expect(provider.default_record_class_name).to eq("#{default_metadata_prefix}_document")
	end

	describe "record_class=" do
		it "is a pending example"
	end
end
