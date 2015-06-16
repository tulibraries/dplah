require 'rails_helper'

RSpec.describe ThumbnailUtils do

  let (:config) { YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__)) }
  let (:pid_prefix) { config['pid_prefix'] }

  before(:all) do
    OaiRec.destroy_all
  end

  after(:all) do
    OaiRec.destroy_all
  end

  describe "Contentdm.asset_url" do

    let (:pid) { "test-prefix:TEMPLE_p16002coll9_1" }
    let (:thumbnail_url) { "http://cdm16002.contentdm.oclc.org/utils/getthumbnail/collection/p16002coll9/id/1" }

    subject {
      obj = FactoryGirl.create(:oai_rec)
      obj.endpoint_url = "http://cdm16002.contentdm.oclc.org/oai/oai.php"
      obj.thumbnail = "http://example.com/thumbnail.jpg"
      obj.set_spec = "p16002coll9"
      oai_rec = OaiRec.new(pid: pid)
      oai_rec.endpoint_url = obj.endpoint_url
      oai_rec.set_spec =  obj.set_spec
      ThumbnailUtils::CommonRepositories::Contentdm.asset_url(oai_rec)
    }

    it { is_expected.to match(thumbnail_url) }
  end
  
  describe "Bepress.asset_url" do

    let (:thumbnail_url) { "http://example.com/example_collection/1234/thumbnail.jpg" }

    subject {
      oai_rec = FactoryGirl.create(:oai_rec)
      oai_rec.description = ["http://example.com/example_collection/1234/thumbnail.jpg"]
      ThumbnailUtils::CommonRepositories::Bepress.asset_url(oai_rec)
    }

    it { is_expected.to match(thumbnail_url) }

  end
  
  describe "Vudl.asset_url" do

    let (:thumbnail_url) { "http://digital.library.example.com/files/vudl:1234/THUMBNAIL" }

    subject {
      oai_rec = FactoryGirl.create(:oai_rec)
      oai_rec.identifier = ["http://digital.library.example.com/Record/vudl:1234"]
      ThumbnailUtils::CommonRepositories::Vudl.asset_url(oai_rec)
    }

    it { is_expected.to match(thumbnail_url) }

  end
  
  describe "Omeka.asset_url" do

    let (:thumbnail_url) { "http://omeka.example.com/files/thumbnails/example_thumbnail.jpg" }

    subject {
      oai_rec = FactoryGirl.create(:oai_rec)
      oai_rec.identifier = ["http://omeka.example.com/files/thumbnails/example_thumbnail.jpg"]
      ThumbnailUtils::CommonRepositories::Omeka.asset_url(oai_rec)
    }

    it { is_expected.to match(thumbnail_url) }

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
