require 'rails_helper'
require 'securerandom'

RSpec.describe HarvestUtils do
  let (:config) { YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__)) }
  let (:pid_prefix) { config['pid_prefix'] }
  let (:download_directory) { config['harvest_data_directory'] }
  let (:convert_directory) { config['converted_foxml_directory'] }
  let (:harvest_fixtures_directory) { File.join("spec", "fixtures", "harvest_data") }
  let (:convert_fixtures_directory) { File.join("spec", "fixtures", "converted_foxml") }
  let (:schema_url) { "http://www.fedora.info/definitions/1/0/foxml1-1.xsd" }
  let (:log_name) { "harvest_utils_spec" }

  let(:provider_small_collection) { FactoryGirl.build(:provider_small_collection) }

  context "Harvest Records" do


    before :each do
      # Make sure sure download directory is empty
      FileUtils.rm Dir.glob "#{download_directory}/*.xml"

      # Make we are starting fresh
      file_count = Dir[File.join(download_directory, '*.xml')].count { |file| File.file?(file) }

      # Create the harvest log file
      HarvestUtils::create_log_file(log_name)

    end

    after :each do
      # Delete the harvested test files
      FileUtils.rm Dir.glob "#{download_directory}/*.xml"
    end

    xit "should harvest a collection" do
      # Harvest the collection
      sso = stdout_to_null
      VCR.use_cassette "harvest_utils/provider_small_collection" do
        HarvestUtils::harvest(provider_small_collection)
      end
      $stdout = sso

      # Expect that we've harvest just one file
      files = Dir[File.join(download_directory, '*.xml')]
      expect(files.count).to eq(1)

      # Expect the harvested file to have representative metadata
      doc = Nokogiri::XML(File.read(files.first))
      expect(doc.xpath("//manifest/set_spec").first.text).to eq(provider_small_collection.set)
      expect(doc.xpath("//manifest/collection_name").first.text).to eq(provider_small_collection.collection_name)
      expect(doc.xpath("//manifest/contributing_institution").first.text).to eq(provider_small_collection.contributing_institution)
    end

#[TODO]    it "should log the harvest"

  end

  context "Harvest with Resumption Token" do
    let(:provider_resumption_token) { FactoryGirl.build(:provider_resumption_token) }

    before :each do
      # Make sure sure download directory is empty
      FileUtils.rm Dir.glob "#{download_directory}/*.xml"

      # Make we are starting fresh
      file_count = Dir[File.join(download_directory, '*.xml')].count { |file| File.file?(file) }

      # Create the harvest log file
      HarvestUtils::create_log_file(log_name)

      # Harvest the collection
      sso = stdout_to_null
      VCR.use_cassette "harvest_utils/provider_resumption_token" do
        HarvestUtils::harvest(provider_resumption_token)
      end
      $stdout = sso

    end

    after :each do
      # Delete the harvested test files
      FileUtils.rm Dir.glob "#{download_directory}/*.xml"

    end

    xit "should harvest collection with a resumption token" do
      # Expect that we've harvest just two files
      file_count = Dir[File.join(download_directory, '*.xml')].count { |file| File.file?(file) }
      expect(file_count).to eq(2)
    end
  end


  context "Convert Records" do

    before :each do
      # Make sure conversion directory is empty
      FileUtils.rm Dir.glob "#{convert_directory}/*.xml"

      # Create the harvest log file
      HarvestUtils::create_log_file(log_name)

      # Get the schema
      VCR.use_cassette "harvest_utils/XML_schema" do
        @xsd = Nokogiri::XML::Schema(open(schema_url))
      end

      # Simulate data harvest
      FileUtils.cp File.join(harvest_fixtures_directory, "harvest_data.xml"), download_directory
    end

    after :each do
      # Clean up the conversion directory
      #FileUtils.rm Dir.glob "#{convert_directory}/*.xml"
    end

    it "should convert a collection" do

      provider = instance_double("provider", metadata_prefix: "oai_dc")

      # Convert the harvested file
      #sso = stdout_to_null
      HarvestUtils::convert(provider)
      #$stdout = sso

      # Expect the file to be valid
      Dir.glob(File.join(convert_directory, '**', '*.xml')).each do |file|
        doc = Nokogiri::XML(File.read(file))
        @xsd.validate(doc).each do |error|
          puts error
        end
        expect(@xsd.valid?(doc)).to be
      end
    end

    xit "is expected to generate a file for each record in the harvest file" do
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

      HarvestUtils::create_log_file(log_name)

      # Simulate data harvest
      FileUtils.cp_r File.join(convert_fixtures_directory, "cleanup", "."), download_directory

      VCR.use_cassette "harvest_utils/XML_schema" do
        @xsd = Nokogiri::XML::Schema(open(schema_url))
      end
    end

    after :each do
      FileUtils.rm Dir.glob "#{convert_directory}/*.xml"
    end

    it 'something' do

    end

    xit "expect valid XML" do
      HarvestUtils::cleanup(provider_small_collection)
      Dir.glob(File.join(convert_directory, '**', '*.xml')).each do |file|
        doc = Nokogiri::XML(File.read(file))
        @xsd.validate(doc).each do |error|
          puts error
        end
        expect(@xsd.valid?(doc)).to be
      end
    end

    xit "expect conformed XML" do
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
      ActiveFedora::Base.destroy_all
      @pid = "#{pid_prefix}:#{SecureRandom.uuid}"
      ActionMailer::Base.deliveries = []
    end

    it "has deletes all records for the collection" do
      ActiveFedora::Base.create({pid: @pid})
      expect(ActiveFedora::Base.count).to_not eq 0
      HarvestUtils::delete_all
      expect(ActiveFedora::Base.count).to eq 0

      mail_deliveries = ActionMailer::Base.deliveries.uniq
      expect(mail_deliveries.size).to eq 1
      expect(mail_deliveries.last.subject).to match /#{I18n.t 'dpla.harvest_mailer.dump_whole_index_subject' }/
    end
  end

  context "Ingest Records" do
    let (:pid) { "test-prefix:temple_p16002coll2_1" }
    before(:each) do
      # Clean out all records
      ActiveFedora::Base.destroy_all

      # Make sure conversion directory is empty
      FileUtils.rm Dir.glob "#{convert_directory}/*.xml"

      # Simulate data harvest
      FileUtils.cp_r File.join(convert_fixtures_directory, "ingest", "."), convert_directory
      
      # Create the harvest log file
      HarvestUtils::create_log_file(log_name)
    end

    after(:each) do
      # Clean out all records
      ActiveFedora::Base.destroy_all
    end

    it "Ingests one object" do
      HarvestUtils::ingest(provider_small_collection)
      expect(ActiveFedora::Base.count).to eq 1
      expect(ActiveFedora::Base.first.pid).to eq pid
    end
  end

  describe "cleanout_and_reindex" do
    let (:dummy_count) { 1 }

    it "reindexes by set" do
      reindex_by = "set"
      allow(HarvestUtils).to receive(:remove_selective).with(provider_small_collection, reindex_by) { dummy_count }
      count = HarvestUtils::cleanout_and_reindex(provider_small_collection, {reindex_by: reindex_by})
      expect(count).to eq dummy_count
    end

    it "reindexes by institution" do
      reindex_by = "institution"
      allow(HarvestUtils).to receive(:remove_selective).with(provider_small_collection, reindex_by) { dummy_count }
      count = HarvestUtils::cleanout_and_reindex(provider_small_collection, {reindex_by: reindex_by})
      expect(count).to eq dummy_count
    end
  end

  context "Harvest Actions" do

    before :each do
      # Make sure harvest directories are empty
      FileUtils.rm Dir.glob "#{download_directory}/*.xml"
      FileUtils.rm Dir.glob "#{convert_directory}/*.xml"

      # Start with fresh Fedora test database
      ActiveFedora::Base.destroy_all

      # Create the harvest log file
      HarvestUtils::create_log_file(log_name)
    end

    after :each do
      # Delete the harvested test files
      FileUtils.rm Dir.glob "#{download_directory}/*.xml"
      FileUtils.rm Dir.glob "#{convert_directory}/*.xml"
    end

    describe "Single harvest action" do

      xit "should harvest the collection" do
        # Harvest the collection
        sso = stdout_to_null
        VCR.use_cassette "harvest_utils/provider_small_collection" do
          HarvestUtils::harvest_action(provider_small_collection)
        end
        $stdout = sso

        # Expect it harvested records
        expect(ActiveFedora::Base.count).to eq(6)
      end

    end

    describe "Harvest Action All from Contributing Institution" do

      before :each do
        provider_small_collection.save
      end

      xit "should harvest a collection" do
        # Harvest the collection
        sso = stdout_to_null
        VCR.use_cassette "harvest_utils/provider_small_collection" do
          HarvestUtils::harvest_all_selective(provider_small_collection)
        end
        $stdout = sso

        # Expect it harvested records
        expect(ActiveFedora::Base.count).to eq(6)
      end

    end

  end


  describe "remove_selective" do

    before :each do
      # Start with fresh Fedora repository
      ActiveFedora::Base.destroy_all

      # Simulate data harvest
      FileUtils.cp_r File.join(convert_fixtures_directory, "ingest", "."), convert_directory
      HarvestUtils::ingest(provider_small_collection)

      @initial_count = ActiveFedora::Base.count
    end

    xit "removes objects by set" do
      HarvestUtils::remove_selective(provider_small_collection, "set")
      expect(ActiveFedora::Base.count).to_not eq(@initial_count)
      expect(ActiveFedora::Base.count).to eq(0)
    end

    xit "removes objects by institution" do
      HarvestUtils::remove_selective(provider_small_collection, "institution")
      expect(ActiveFedora::Base.count).to_not eq(@initial_count)
      expect(ActiveFedora::Base.count).to eq(0)
    end

    xit "rejects non set and insitution option" do
      expect(lambda{HarvestUtils::remove_selective(provider_small_collection, "")}).to raise_error SystemExit
      expect(ActiveFedora::Base.count).to eq(@initial_count)
      expect(ActiveFedora::Base.count).to_not eq(0)
    end

  end

  describe '#conform_urls' do
    let(:uppercase_url) {"HTTP://EXAMPLE.COM/SOMEOTHERTHING"}
    let(:rightsstatement) {"http://rightsstatements.org/vocab/InC-RUU/1.0/"}

    it 'ensure http urls start with lower case protocol' do
      expect(HarvestUtils::conform_url(uppercase_url)).to start_with 'http'
    end

    it "doesn't alter url path" do
      expect(HarvestUtils::conform_url(rightsstatement)).to include "/vocab/InC-RUU/1.0/"
    end

  end

end
