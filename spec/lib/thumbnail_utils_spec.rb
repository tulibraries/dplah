require 'rails_helper'

RSpec.describe ThumbnailUtils do
  let (:config) { YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__)) }

  describe "Contentdm.asset_url" do
    it "should render a valid URL"
  end
  
  describe "Bepress.asset_url" do
    it "should render a valid URL"
  end
  
  describe "Vudl.asset_url" do
    it "should render a valid URL"
  end
  
  describe "Omeka.asset_url" do
    it "should render a valid URL"
  end

  context "define_thumbnail_common" do
    it "should render a valid CONTENTdm URL"
    it "should render a valid Bepress thumbnail URL"
    it "should render a valid VuDL thumbnail URL"
    it "should render a valid Omeka thumbnail URL"
  end

  describe "define_thumbnail_pattern" do

  end

  describe "set_thumbnail" do
    
  end
end
