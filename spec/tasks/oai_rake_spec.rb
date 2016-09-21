require 'rails_helper'
require 'rake'

RSpec.describe 'oai.rake' do

  let (:config) { YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__)) }
  let (:pid_prefix) { config['pid_prefix'] }
  let (:download_directory) { config['harvest_data_directory'] }
  let (:convert_directory) { config['converted_foxml_directory'] }
  let (:log_name) { "harvest_utils_spec" }
  let (:provider_small_collection) { FactoryGirl.build(:provider_small_collection) }

  before :each do
    Rake.application.rake_require "tasks/oai"
    Rake::Task.define_task(:environment)
    HarvestUtils::create_log_file(log_name)
    ActiveFedora::Base.destroy_all
    FileUtils.rm Dir.glob "#{convert_directory}/*.xml"
    FileUtils.rm Dir.glob "#{download_directory}/*.xml"
    provider_small_collection.save
  end

  after :each do
    FileUtils.rm Dir.glob "#{convert_directory}/*.xml"
    FileUtils.rm Dir.glob "#{download_directory}/*.xml"
    ActiveFedora::Base.destroy_all
  end

  context 'Harvesting' do

    after :each do
      Rake::Task['oai:harvest'].reenable
    end

    describe 'oai:harvest' do
      xit 'harvests one OAI seed' do
        sso = stdout_to_null
        VCR.use_cassette "oai_rake/provider_small_collection" do
          Rake::Task['oai:harvest'].invoke(provider_small_collection.id)
        end
        $stdout = sso

        file_count = Dir[File.join(download_directory, '*.xml')].count { |file| File.file?(file) }
        expect(file_count).to eq(1)
      end

      xit 'throws an error for an invalid OAI seed' do
        output = capture(:stdout) do
          Rake::Task['oai:harvest'].invoke
        end

        file_count = Dir[File.join(download_directory, '*.xml')].count { |file| File.file?(file) }
        expect(file_count).to eq(0)
        expect(output).to match "No valid OAI Seed model ID entered. To harvest all, run rake oai:harvest_all."
      end
    end

    describe 'oai:harvest_all' do
      xit 'harvests records from all OAI providers and ingests into the repository' do
        sso = stdout_to_null
        VCR.use_cassette "oai_rake/provider_small_collection" do
          Rake::Task['oai:harvest_all'].invoke
        end
        $stdout = sso

        file_count = Dir[File.join(download_directory, '*.xml')].count { |file| File.file?(file) }
        expect(file_count).to eq(1)
      end
    end

    describe 'oai:harvest_ingest_all' do
      xit 'harvests records from all OAI providers and ingests into the repository' do
        sso = stdout_to_null
        VCR.use_cassette "oai_rake/provider_small_collection" do
          Rake::Task['oai:harvest_ingest_all'].invoke
        end
        $stdout = sso

        expect(ActiveFedora::Base.count).to eq(6)
      end
    end

    describe 'oai:convert_all' do
      xit 'converts all XML harvests currently in the harvested directory to FOXML' do
        sso = stdout_to_null
        VCR.use_cassette "oai_rake/convert_all" do
          HarvestUtils::harvest(provider_small_collection)
          Rake::Task['oai:convert_all'].invoke
        end
        $stdout = sso

        file_count = Dir[File.join(convert_directory, '*.xml')].count { |file| File.file?(file) }
        expect(file_count).to eq(6)
      end

    end

  end

  describe 'oai:delete_all' do

    before :each do
      sso = stdout_to_null
      Rake::Task['oai:harvest_ingest_all'].invoke
      $stdout = sso
    end

    xit 'deletes all OAI objects from the repository' do
      sso = stdout_to_null
      Rake::Task['oai:delete_all'].invoke
      $stdout = sso

      expect(ActiveFedora::Base.count).to eq(0)
    end
  end

end
