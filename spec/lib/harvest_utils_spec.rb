require 'rails_helper'
require 'securerandom'

RSpec.describe HarvestUtils do
  let (:config) { YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__)) }
  let (:pid_prefix) { config['pid_prefix'] }
  let (:download_directory) { config['harvest_data_directory'] }
  let (:convert_directory) { config['converted_foxml_directory'] }
  let (:schema_url) { "http://www.fedora.info/definitions/1/0/foxml1-1.xsd" }
  let (:log_name) { "harvest_utils_spec" }

  let(:provider_small_collection) { FactoryGirl.build(:provider_small_collection) }

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
      HarvestUtils::create_log_file(log_name)
      sso = stdout_to_null
      VCR.use_cassette "harvest_utils/provider_small_collection" do
        HarvestUtils::harvest(provider_small_collection)
      end
      $stdout = sso

      # Expect that we've harvest just one file
      file_count = Dir[File.join(download_directory, '*.xml')].count { |file| File.file?(file) }
      expect(file_count).to eq(1)
      file = Dir[File.join(download_directory, '*.xml')].first
      doc = Nokogiri::XML(File.read(file))

      # Expect the harvested file to have representative metadata 
      expect(doc.xpath("//manifest/set_spec").first.text).to eq(provider_small_collection.set)
      expect(doc.xpath("//manifest/collection_name").first.text).to eq(provider_small_collection.collection_name)
      #expect(doc.xpath("//manifest/provider_id_prefix").first.text).to eq(provider_small_collection.contributing_institution)
      expect(doc.xpath("//manifest/contributing_institution").first.text).to eq(provider_small_collection.contributing_institution)
    end

    it "should log the harvest"

  end

  context "Convert Records" do

    before :each do
      # Make sure conversion directory is empty
      FileUtils.rm Dir.glob "#{convert_directory}/*.xml"

      # Harvest a file to convert
      HarvestUtils::create_log_file(log_name)
      sso = stdout_to_null
      VCR.use_cassette "harvest_utils/provider_small_collection" do
        HarvestUtils::harvest(provider_small_collection)
      end
      $stdout = sso

      # Get the schema
      VCR.use_cassette "harvest_utils/XML_schema" do
        @xsd = Nokogiri::XML::Schema(open(schema_url))
      end

    end

    after :each do
      # Clean up the conversion directory
      FileUtils.rm Dir.glob "#{convert_directory}/*.xml"
    end

    it "should convert a collection" do

      # Convert the harvested file
      sso = stdout_to_null
      HarvestUtils::convert(provider_small_collection)
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
      HarvestUtils::convert(provider_small_collection)
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
      FileUtils.rm Dir.glob "#{convert_directory}/*.xml"

      sso = stdout_to_null
      HarvestUtils::create_log_file(log_name)
      VCR.use_cassette "harvest_utils/provider_small_collection" do
        HarvestUtils::harvest(provider_small_collection)
      end
      HarvestUtils::convert(provider_small_collection)
      $stdout = sso

      VCR.use_cassette "harvest_utils/XML_schema" do
        @xsd = Nokogiri::XML::Schema(open(schema_url))
      end

      sso = stdout_to_null
      HarvestUtils::convert(provider_small_collection)
      $stdout = sso

    end

    after :each do
      FileUtils.rm Dir.glob "#{convert_directory}/*.xml"
    end

    it "expect valid XML" do
      HarvestUtils::cleanup(provider_small_collection)
      Dir.glob(File.join(convert_directory, '**', '*.xml')).each do |file|
        doc = Nokogiri::XML(File.read(file))
        @xsd.validate(doc).each do |error|
          puts error
        end
        expect(@xsd.valid?(doc)).to be
      end
    end

    it "expect conformed XML" do
      trailing_separator = /[\,;\.]$/
      # Copy non-conforming test fixture to convert directory
      Dir.glob(File.join(Rails.root, 'spec', 'fixtures', 'converted_foxml', 'cleanup', '*.xml')).each do |file|
        FileUtils.cp file, File.join(convert_directory, File.basename(file))
      end
      # Clean up
      HarvestUtils::cleanup(provider_small_collection)
      Dir.glob(File.join(convert_directory, '**', '*.xml')).each do |file|
        doc = Nokogiri::XML(File.read(file))
        doc.xpath("//subject").each { |s| expect(trailing_separator).to_not match(s.text) }
        doc.xpath("//type").each { |t| expect(trailing_separator).to_not match(t.text) }
      end
    end
  end

  context "Delete Records" do
    before(:each) do
      @pid = "#{pid_prefix}:#{SecureRandom.uuid}"
    end

    it "has deletes all records for the collection" do
      ActiveFedora::Base.create({pid: @pid})
      expect(ActiveFedora::Base.count).to_not eq 0
      HarvestUtils::delete_all 
      expect(ActiveFedora::Base.count).to eq 0
    end
  end

  context "Ingest Records" do
    let (:pid) { "dplapa:_alycc_voice_0" }
    before(:each) do
      # Clean out all records
      ActiveFedora::Base.destroy_all

      # Make sure conversion directory is empty
      FileUtils.rm Dir.glob "#{convert_directory}/*.xml"

      # Harvest a file to convert
      HarvestUtils::create_log_file(log_name)
    end

    after(:each) do
      # Clean out all records
      ActiveFedora::Base.destroy_all
    end

    it "Ingests one object" do
      # Copy ingest test fixture to convert directory
      Dir.glob(File.join(Rails.root, 'spec', 'fixtures', 'converted_foxml', 'ingest', '*.xml')).each do |file|
        FileUtils.cp file, File.join(convert_directory, File.basename(file))
      end

      HarvestUtils::ingest(provider_small_collection)
      expect(ActiveFedora::Base.count).to eq 1
      expect(ActiveFedora::Base.first.pid).to eq pid
    end

  end
end
