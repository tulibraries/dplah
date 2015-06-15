require 'rails_helper'

RSpec.describe ThumbnailUtils do

  let (:config) { YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__)) }
  let (:pid_prefix) { config['pid_prefix'] }

  describe "Contentdm.asset_url" do

    let (:pid) { "test-prefix:TEMPLE_p16002coll9_1" }
    let (:thumbnail_url) { "http://cdm16002.contentdm.oclc.org/utils/getthumbnail/collection/p16002coll9/id/1" }

    subject {
      obj = FactoryGirl.create(:oai_rec_contentdm)
      oai_rec = OaiRec.new(pid: pid)
      oai_rec.endpoint_url = obj.endpoint_url
      oai_rec.set_spec =  obj.set_spec
      ThumbnailUtils::CommonRepositories::Contentdm.asset_url(oai_rec)
    }

    it { is_expected.to match(thumbnail_url) }
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
