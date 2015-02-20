require 'rails_helper'

RSpec.describe OaiRec, :type => :model do
  context 'OaiRec Class' do
    subject { OaiRec.new }

    it { is_expected.to have_metadata_stream_of_type(Datastreams::OaiRecMetadata) }

    it { is_expected.to respond_to(:creator) }
	  it { is_expected.to respond_to(:title) }
	  it { is_expected.to respond_to(:subject) }
	  it { is_expected.to respond_to(:subject) }
	  it { is_expected.to respond_to(:description) }
	  it { is_expected.to respond_to(:publisher) }
	  it { is_expected.to respond_to(:contributor) }
	  it { is_expected.to respond_to(:date) }
	  it { is_expected.to respond_to(:type) }
	  it { is_expected.to respond_to(:format) }
	  it { is_expected.to respond_to(:identifier) }
	  it { is_expected.to respond_to(:source) }
	  it { is_expected.to respond_to(:language) }
	  it { is_expected.to respond_to(:relation) }
	  it { is_expected.to respond_to(:coverage) }
	  it { is_expected.to respond_to(:rights) }

	  it { is_expected.to respond_to(:contributing_institution) }
	  it { is_expected.to respond_to(:collection_name) }
	  it { is_expected.to respond_to(:partner) }

	  it { is_expected.to respond_to(:set_spec) }
  end

  context 'OaiRec Object' do

    before(:context) do
      @o = FactoryGirl.build(:oai_rec)
      oaiRec = OaiRec.create(title: @o.title,
                             creator: @o.creator,
                             subject: @o.subject,
                             description: @o.description,
                             publisher: @o.publisher,
                             contributor: @o.contributor,
                             date: @o.date,
                             type: @o.type,
                             format: @o.format,
                             identifier: @o.identifier,
                             source: @o.source,
                             language: @o.language,
                             relation: @o.relation,
                             coverage: @o.coverage,
                             rights: @o.rights,
                             contributing_institution: @o.contributing_institution,
                             collection_name: @o.collection_name,
                             partner: @o.partner,
                             set_spec: @o.set_spec)
      oaiRec.update_index
      @object = ActiveFedora::Base.where(identifier_tesim: @o.identifier).to_a.first
    end

    after(:context) do
      OaiRec.delete_all
    end

    it "should find the object" do
      expect(@object.identifier).to eq(@o.identifier)
    end

    it "should match the title" do
      expect(@object.title).to eq(@o.title)
    end

    it "should match the creator" do
      expect(@object.creator).to eq(@o.creator)
    end

    it "should match the subject" do
      expect(@object.subject).to eq(@o.subject)
    end

    it "should match the description" do
      expect(@object.description).to eq(@o.description)
    end

    it "should match the publisher" do
      expect(@object.publisher).to eq(@o.publisher)
    end

    it "should match the contributor" do
      expect(@object.contributor).to eq(@o.contributor)
    end

    it "should match the date" do
      expect(@object.date).to eq(@o.date)
    end

    it "should match the type" do
      expect(@object.type).to eq(@o.type)
    end

    it "should match the format" do
      expect(@object.format).to eq(@o.format)
    end

    it "should match the identifier" do
      expect(@object.identifier).to eq(@o.identifier)
    end

    it "should match the source" do
      expect(@object.source).to eq(@o.source)
    end

    it "should match the language" do
      expect(@object.language).to eq(@o.language)
    end

    it "should match the relation" do
      expect(@object.relation).to eq(@o.relation)
    end

    it "should match the coverage" do
      expect(@object.coverage).to eq(@o.coverage)
    end

    it "should match the rights" do
      expect(@object.rights).to eq(@o.rights)
    end

    it "should match the contributing institution" do
      expect(@object.contributing_institution).to eq(@o.contributing_institution)
    end

    it "should match the collection name" do
      expect(@object.collection_name).to eq(@o.collection_name)
    end

    it "should match the partner" do
      expect(@object.partner).to eq(@o.partner)
    end

    it "should match the set spec" do
      expect(@object.set_spec).to eq(@o.set_spec)
    end
  end

end
