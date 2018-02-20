require 'rails_helper'

RSpec.describe "oai_recs/show", :type => :view do
  skip "Travis-CI Fail: 503 Service Unavailable" do
  before(:each) do
    @oai_rec = assign(:oai_rec, OaiRec.create!(
      :title => ["Title"],
      :creator => ["Creator"],
      :subject => ["Subject"],
      :description => ["Description"],
      :publisher => ["Publisher"],
      :contributor => ["Contributor"],
      :date => ["Date"],
      :type => ["Type"],
      :format => ["Format"],
      :identifier => ["Identifier"],
      :source => ["Source"],
      :language => ["Language"],
      :relation => ["Relation"],
      :coverage => ["Coverage"],
      :rights => ["Rights"]
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Creator/)
    expect(rendered).to match(/Subject/)
    expect(rendered).to match(/Description/)
    expect(rendered).to match(/Publisher/)
    expect(rendered).to match(/Contributor/)
    expect(rendered).to match(/Date/)
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/Format/)
    expect(rendered).to match(/Identifier/)
    expect(rendered).to match(/Source/)
    expect(rendered).to match(/Language/)
    expect(rendered).to match(/Relation/)
    expect(rendered).to match(/Coverage/)
    expect(rendered).to match(/Rights/)
  end
  end # Skip
end
