require 'rails_helper'

describe "OaiRecMetadata" do

  subject { OaiRecMetadata.new }

  it { is_expected.to have_term(:title) }
  it { is_expected.to have_term(:creator) }
  it { is_expected.to have_term(:subject) }
  it { is_expected.to have_term(:description) }
  it { is_expected.to have_term(:publisher) }
  it { is_expected.to have_term(:contributor) }
  it { is_expected.to have_term(:date) }
  it { is_expected.to have_term(:type) }
  it { is_expected.to have_term(:format) }
  it { is_expected.to have_term(:identifier) }
  it { is_expected.to have_term(:source) }
  it { is_expected.to have_term(:language) }
  it { is_expected.to have_term(:relation) }
  it { is_expected.to have_term(:coverage) }
  it { is_expected.to have_term(:rights) }
  it { is_expected.to have_term(:contributing_institution) }
  it { is_expected.to have_term(:partner) }

end
