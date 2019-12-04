require 'rails_helper'

RSpec.describe ThumbnailUtils do
  skip "TRAVIS-CI Fails: 503 Service Unavailable" do

  let (:config) { YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__)) }
  let (:pid_prefix) { config['pid_prefix'] }
  let (:contentdm_thumbnail_url) { "http://cdm16002.contentdm.oclc.org/utils/getthumbnail/collection/p16002coll9/id/1" }
  let (:contentdm_pid) { "test-prefix:TEMPLE_p16002coll9_1" }
  let (:bepress_thumbnail_url) { "http://example.com/example_collection/1234/thumbnail.jpg" }
  let (:vudl_thumbnail_url) { "http://digital.library.example.com/files/vudl:1234/THUMBNAIL" }
  let (:omeka_thumbnail_url) { "http://omeka.example.com/files/thumbnails/example_thumbnail.jpg" }
  let (:default_thumbnail) { "default-thumbnail.png" }


  before(:all) do
    OaiRec.destroy_all
  end

  after(:all) do
    OaiRec.destroy_all
  end

  describe "Contentdm.asset_url" do

    subject {
      obj = FactoryBot.create(:oai_rec)
      obj.endpoint_url = "http://cdm16002.contentdm.oclc.org/oai/oai.php"
      obj.thumbnail = "http://example.com/thumbnail.jpg"
      obj.set_spec = "p16002coll9"
      oai_rec = OaiRec.new(pid: contentdm_pid)
      oai_rec.endpoint_url = obj.endpoint_url
      oai_rec.set_spec =  obj.set_spec
      ThumbnailUtils::CommonRepositories::Contentdm.asset_url(oai_rec)
    }

    it { is_expected.to match(contentdm_thumbnail_url) }
  end

  describe "Bepress.asset_url" do

    subject {
      oai_rec = FactoryBot.create(:oai_rec)
      oai_rec.description = ["http://example.com/example_collection/1234/thumbnail.jpg"]
      ThumbnailUtils::CommonRepositories::Bepress.asset_url(oai_rec)
    }

    it { is_expected.to match(bepress_thumbnail_url) }

  end

  describe "Vudl.asset_url" do

    subject {
      oai_rec = FactoryBot.create(:oai_rec)
      oai_rec.identifier = ["http://digital.library.example.com/Record/vudl:1234"]
      ThumbnailUtils::CommonRepositories::Vudl.asset_url(oai_rec)
    }

    it { is_expected.to match(vudl_thumbnail_url) }

  end

  describe "Omeka.asset_url" do

    subject {
      oai_rec = FactoryBot.create(:oai_rec)
      oai_rec.identifier = ["http://omeka.example.com/files/thumbnails/example_thumbnail.jpg"]
      ThumbnailUtils::CommonRepositories::Omeka.asset_url(oai_rec)
    }

    it { is_expected.to match(omeka_thumbnail_url) }

  end

  context "define_thumbnail_common" do

    before (:each) do
      @provider = FactoryBot.create(:provider)
    end

    describe "CONTENTdm provider" do

      it "is a thumbnail URL" do
        @provider.common_repository_type = "CONTENTdm"
        obj = FactoryBot.create(:oai_rec)
        obj.endpoint_url = "http://cdm16002.contentdm.oclc.org/oai/oai.php"
        obj.thumbnail = "http://example.com/thumbnail.jpg"
        obj.set_spec = "p16002coll9"
        oai_rec = OaiRec.new(pid: contentdm_pid)
        oai_rec.endpoint_url = obj.endpoint_url
        oai_rec.set_spec =  obj.set_spec
        thumbnail_url = ThumbnailUtils.define_thumbnail_common(oai_rec, @provider)

        expect(thumbnail_url).to match(contentdm_thumbnail_url)
      end

    end

    describe "Bepress provider" do
      it "is a thumbnail URL" do
        @provider.common_repository_type = "Bepress"
        oai_rec = FactoryBot.create(:oai_rec)
        oai_rec.description = ["http://example.com/example_collection/1234/thumbnail.jpg"]
        thumbnail_url = ThumbnailUtils.define_thumbnail_common(oai_rec, @provider)

        expect(thumbnail_url).to match(bepress_thumbnail_url)
      end
    end

    describe "VuDL provider" do
      it "is a thumbnail URL" do
        @provider.common_repository_type = "VuDL"
        oai_rec = FactoryBot.create(:oai_rec)
        oai_rec.identifier = ["http://digital.library.example.com/Record/vudl:1234"]
        thumbnail_url = ThumbnailUtils.define_thumbnail_common(oai_rec, @provider)

        expect(thumbnail_url).to match(vudl_thumbnail_url)
      end
    end

    describe "Omeka provider" do
      it "is a thumbnail URL" do
        @provider.common_repository_type = "Omeka"
        oai_rec = FactoryBot.create(:oai_rec)
        oai_rec.identifier = ["http://omeka.example.com/files/thumbnails/example_thumbnail.jpg"]
        thumbnail_url = ThumbnailUtils.define_thumbnail_common(oai_rec, @provider)

        expect(thumbnail_url).to match(omeka_thumbnail_url)
      end
    end

    describe "Invalid provider" do
      it "is a thumbnail URL" do
        common_repository_type = "Fake Repository"
        @provider.common_repository_type = common_repository_type
        oai_rec = FactoryBot.create(:oai_rec)
        expect(lambda{ThumbnailUtils.define_thumbnail_common(oai_rec, @provider)}).to raise_error SystemExit
      end

    end
  end

  describe "define_thumbnail_pattern" do

    let (:thumbnail_pattern_both) { "http://example.com/oai/$1/thumbnails/$2.jpg" }
    let (:thumbnail_pattern_first) { "http://example.com/oai/thumbnails/$1.jpg" }
    let (:thumbnail_pattern_second) { "http://example.com/oai/thumbnails/$2.jpg" }
    let (:thumbnail_pattern_wheeler) { "http://example.com/oai/$1/thumbnails/$2.jpg" }
    let (:thumbnail_token_1) { "source" }
    let (:thumbnail_token_2) { "identifier" }
    let (:custom_thumbnail_url_both) { "http://example.com/oai/coll1/thumbnails/object1.jpg" }
    let (:custom_thumbnail_url_first) { "http://example.com/oai/thumbnails/object1.jpg" }
    let (:custom_thumbnail_url_second) { "http://example.com/oai/thumbnails/object1.jpg" }
    let (:source) { "coll1" }
    let (:identifier) { "object1" }

    let (:oai_rec) {
      obj = FactoryBot.create(:oai_rec)
      obj.source << source
      obj.identifier << identifier
      obj
    }

    it "defines a thumbnail pattern with both parameters defined" do
      provider = FactoryBot.create(:provider)
      provider.thumbnail_pattern = thumbnail_pattern_both
      provider.thumbnail_token_1 = thumbnail_token_1
      provider.thumbnail_token_2 = thumbnail_token_2
      thumbnail_url = ThumbnailUtils.define_thumbnail_pattern(oai_rec, provider)

      expect(thumbnail_url).to match(custom_thumbnail_url_both)
    end

    it "defines a thumbnail pattern with only first parameter defined" do
      provider = FactoryBot.create(:provider)
      provider.thumbnail_pattern = thumbnail_pattern_first
      provider.thumbnail_token_1 = thumbnail_token_2
      provider.thumbnail_token_2 = ""
      thumbnail_url = ThumbnailUtils.define_thumbnail_pattern(oai_rec, provider)

      expect(thumbnail_url).to match(custom_thumbnail_url_first)
    end

    it "defines a thumbnail pattern with only second parameter defined" do
      provider = FactoryBot.create(:provider)
      provider.thumbnail_pattern = thumbnail_pattern_second
      provider.thumbnail_token_1 = ""
      provider.thumbnail_token_2 = thumbnail_token_2
      thumbnail_url = ThumbnailUtils.define_thumbnail_pattern(oai_rec, provider)

      expect(thumbnail_url).to match(custom_thumbnail_url_second)
    end

    it "defines a custom thumbnail prefixing with for UPENN Wheeler" do
      token = "WHEELER_object1"
      provider = FactoryBot.create(:provider_upenn_wheeler)
      new_token = ThumbnailUtils.custom_thumbnail_prefixing(token, provider)

      expect(new_token).to match("wheeler_object1")
    end

    it "defines a custom thumbnail prefixing with for UPENN Holy Land" do
      token = "HOLYLAND_object1"
      provider = FactoryBot.create(:provider_upenn_holyland)
      new_token = ThumbnailUtils.custom_thumbnail_prefixing(token, provider)

      expect(new_token).to match("object1")
    end

    it "defines a custom thumbnail prefixing with for UPENN Archives" do
      token = "ARCHIVES_object1"
      provider = FactoryBot.create(:provider_upenn_archives)
      new_token = ThumbnailUtils.custom_thumbnail_prefixing(token, provider)

      expect(new_token).to match("archives_object1")
    end

  end

  describe "define_thumbnail" do
    let (:oai_rec) { FactoryBot.create(:oai_rec) }
    let (:thumbnail_pattern_both) { "http://example.com/oai/$1/thumbnails/$2.jpg" }
    let (:thumbnail_token_1) { "source" }
    let (:thumbnail_token_2) { "identifier" }
    let (:custom_thumbnail_url_both) { "http://example.com/oai/coll1/thumbnails/object1.jpg" }
    let (:source) { "coll1" }
    let (:identifier) { "object1" }

    it "returns thumbnail with common repository type" do
      provider = FactoryBot.create(:provider)
      provider.common_repository_type = "CONTENTdm"
      obj = FactoryBot.create(:oai_rec)
      obj.endpoint_url = "http://cdm16002.contentdm.oclc.org/oai/oai.php"
      obj.thumbnail = "http://example.com/thumbnail.jpg"
      obj.set_spec = "p16002coll9"
      oai_rec = OaiRec.new(pid: contentdm_pid)
      oai_rec.endpoint_url = obj.endpoint_url
      oai_rec.set_spec =  obj.set_spec
      thumbnail_url = ThumbnailUtils.define_thumbnail(oai_rec, provider)

      expect(thumbnail_url).to match(contentdm_thumbnail_url)
    end

    it "returns thumbnail with thumbnail pattern type" do
      oai_rec = FactoryBot.create(:oai_rec)
      oai_rec.source << source
      oai_rec.identifier << identifier
      provider = FactoryBot.create(:provider)
      provider.thumbnail_pattern = thumbnail_pattern_both
      provider.thumbnail_token_1 = thumbnail_token_1
      provider.thumbnail_token_2 = thumbnail_token_2
      thumbnail_url = ThumbnailUtils.define_thumbnail(oai_rec, provider)

      expect(thumbnail_url).to match(custom_thumbnail_url_both)
    end

    xit "returns default thumbnail" do

      oai_rec = FactoryBot.create(:oai_rec)
      oai_rec.source << ""
      oai_rec.identifier << ""
      provider = FactoryBot.create(:provider)
      provider.thumbnail_pattern = ""
      provider.thumbnail_token_1 = ""
      provider.thumbnail_token_2 = ""
      thumbnail_url = ThumbnailUtils.define_thumbnail(oai_rec, provider)
      expect(thumbnail_url).to match(default_thumbnail)
    end
  end

  end # Skip
end
