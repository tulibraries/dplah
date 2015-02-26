require 'rails_helper'
require 'securerandom'

RSpec.describe HarvestUtils do
  let (:config) { YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__)) }
  let (:pid_prefix) { config["pid_prefix"] }

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
