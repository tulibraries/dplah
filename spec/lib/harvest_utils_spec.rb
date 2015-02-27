require 'rails_helper'
require 'securerandom'

RSpec.describe HarvestUtils do
  let (:config) { YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__)) }
  let (:pid_prefix) { config['pid_prefix'] }
  let (:download_directory) { config['harvest_data_directory'] }
  let (:convert_directory) { config['converted_foxml_directory'] }
  let (:schema_url) { "http://www.fedora.info/definitions/1/0/foxml1-1.xsd" }

  context "Harvest Records" do

    let(:p) { FactoryGirl.build(:provider_small_collection) }
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

    after :each do
      FileUtils.rm Dir.glob "#{download_directory}/*.xml"
    end

    it "should harvest a collection" do
      VCR.use_cassette "harvest_utils/provider_small_collection" do
        HarvestUtils::create_log_file(provider.name)
        HarvestUtils::harvest(p)
      end

      file_count = Dir[File.join(download_directory, '*.xml')].count { |file| File.file?(file) }
      expect(file_count).to eq(1)
      file = Dir[File.join(download_directory, '*.xml')].first
      doc = Nokogiri::XML(File.read(file))
      # Tests for both metadata and attempted access to private collection
      expect(doc.xpath("//manifest/set_spec").first.text).to eq(p.set)
      expect(doc.xpath("//manifest/collection_name").first.text).to eq(p.collection_name)
      expect(doc.xpath("//manifest/contributing_institution").first.text).to eq(p.contributing_institution)
    end
  end

  context "Convert Records" do

    let(:p) { FactoryGirl.build(:provider_small_collection) }

    before :each do
      VCR.use_cassette "harvest_utils/provider_small_collection" do
        HarvestUtils::create_log_file(p.name)
        HarvestUtils::harvest(p)
      end
      VCR.use_cassette "harvest_utils/XML_schema" do
        @xsd = Nokogiri::XML::Schema(open(schema_url))
      end
    end

    after :each do
      FileUtils.rm Dir.glob "#{convert_directory}/*.xml"
    end

    it "should convert a collection" do

      HarvestUtils::convert(p)

      file_count = Dir[File.join(convert_directory, '*.xml')].count { |file| File.file?(file) }
      Dir.glob(File.join(convert_directory, '**', '*.xml')).each do |file|
        doc = Nokogiri::XML(File.read(file))
        @xsd.validate(doc).each do |error|
          puts error
        end
        expect(@xsd.valid?(doc)).to be
      end
    end
  end

  context "Delete Records" do
    before(:each) do
      @pid = "#{pid_prefix}:#{SecureRandom.uuid}"
    end

    it "should have the custom YAML attributes" do
      ActiveFedora::Base.create({pid: @pid})
      expect(ActiveFedora::Base.count).to_not eq 0
      HarvestUtils::delete_all 
      expect(ActiveFedora::Base.count).to eq 0
    end
  end
end
