require 'rails_helper'
require 'securerandom'

RSpec.describe HarvestUtils do
  let (:config) { YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__)) }
  let (:pid_prefix) { config['pid_prefix'] }
  let (:download_directory) { config['harvest_data_directory'] }
  let (:convert_directory) { config['converted_foxml_directory'] }
  let (:schema_url) { "http://www.fedora.info/definitions/1/0/foxml1-1.xsd" }

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

  context "Harvest Records" do

    before :each do
      # Make sure sure download directory is empty
      FileUtils.rm Dir.glob "#{download_directory}/*.xml"
    end

    after :each do
      # Delete the harvested test files 
      FileUtils.rm Dir.glob "#{download_directory}/*.xml"
    end

    it "should harvest a collection" do
      # Make we are starting fresh
      file_count = Dir[File.join(download_directory, '*.xml')].count { |file| File.file?(file) }
      expect(file_count).to eq(0)

      # Harvest the collection
      VCR.use_cassette "harvest_utils/provider_small_collection" do
        HarvestUtils::create_log_file(provider.name)
        sso = stdout_to_null
        HarvestUtils::harvest(p)
        $stdout = sso
      end

      # Expect that we've harvest just one file
      file_count = Dir[File.join(download_directory, '*.xml')].count { |file| File.file?(file) }
      expect(file_count).to eq(1)
      file = Dir[File.join(download_directory, '*.xml')].first
      doc = Nokogiri::XML(File.read(file))

      # Expect the harvested file to have representative metadata 
      expect(doc.xpath("//manifest/set_spec").first.text).to eq(p.set)
      expect(doc.xpath("//manifest/collection_name").first.text).to eq(p.collection_name)
      expect(doc.xpath("//manifest/contributing_institution").first.text).to eq(p.contributing_institution)
    end

    it "should log the harvest"

  end

  context "Convert Records" do

    before :each do
      # Harvest a file to convert
      VCR.use_cassette "harvest_utils/provider_small_collection" do
        HarvestUtils::create_log_file(p.name)
        sso = stdout_to_null
        HarvestUtils::harvest(p)
        $stdout = sso
      end

      # Get the schema
      VCR.use_cassette "harvest_utils/XML_schema" do
        @xsd = Nokogiri::XML::Schema(open(schema_url))
      end

      # Make sure conversion directory is empty
      FileUtils.rm Dir.glob "#{convert_directory}/*.xml"
    end

    after :each do
      # Clean up the conversion directory
      FileUtils.rm Dir.glob "#{convert_directory}/*.xml"
    end

    it "should convert a collection" do

      # Convert the harvested file
      sso = stdout_to_null
      HarvestUtils::convert(p)
      $stdout = sso

      # Expect the file to be valid
      Dir.glob(File.join(convert_directory, '**', '*.xml')).each do |file|
        doc = Nokogiri::XML(File.read(file))
        @xsd.validate(doc).each do |error|
          puts error
        end
        expect(@xsd.valid?(doc)).to be
      end
    end

    it "is expected to generate a file for each record in the harvest file" do
      # Get the record count
      file = Dir[File.join(download_directory, '*.xml')].first
      doc = Nokogiri::XML(File.read(file))
      record_count = doc.xpath("//record").count

      # Convert the harvested file
      sso = stdout_to_null
      HarvestUtils::convert(p)
      $stdout = sso

      # Expect the number of conversion files
      file_count = Dir[File.join(convert_directory, '*.xml')].count { |file| File.file?(file) }
      expect(file_count).to be record_count
    end

    it "should log the conversion"
    it "should remove the harvested files after conversion"

  end

  context "Cleanup Records" do

    before :each do
      VCR.use_cassette "harvest_utils/provider_small_collection" do
        HarvestUtils::create_log_file(p.name)
        sso = stdout_to_null
        HarvestUtils::harvest(p)
        $stdout = sso
      end

      VCR.use_cassette "harvest_utils/XML_schema" do
        @xsd = Nokogiri::XML::Schema(open(schema_url))
      end

      FileUtils.rm Dir.glob "#{convert_directory}/*.xml"
    end

    after :each do
      FileUtils.rm Dir.glob "#{convert_directory}/*.xml"
    end

    it "should clean up the collection" do

      sso = stdout_to_null
      HarvestUtils::convert(p)
      $stdout = sso

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
