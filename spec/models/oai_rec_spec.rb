require 'rails_helper'

RSpec.describe OaiRec, :type => :model do
  context 'OaiRec Class' do
    subject { OaiRec.new }

    it { is_expected.to have_metadata_stream_of_type(OaiRecMetadata) }

    it { is_expected.to respond_to(:creator) }
	  it { is_expected.to respond_to(:title) }
	  it { is_expected.to respond_to(:creator) }
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
	  it { is_expected.to respond_to(:partner) }
  end
end
