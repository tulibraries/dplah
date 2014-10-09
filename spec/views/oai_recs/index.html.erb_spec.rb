require 'rails_helper'

RSpec.describe "oai_recs/index", :type => :view do
  before(:each) do
    assign(:oai_recs, [
      OaiRec.create!(
        :title => "Title",
        :creator => "Creator",
        :subject => "Subject",
        :description => "Description",
        :publisher => "Publisher",
        :contributor => "Contributor",
        :date => "Date",
        :type => "Type",
        :format => "Format",
        :identifier => "Identifier",
        :source => "Source",
        :language => "Language",
        :relation => "Relation",
        :coverage => "Coverage",
        :rights => "Rights"
      ),
      OaiRec.create!(
        :title => "Title",
        :creator => "Creator",
        :subject => "Subject",
        :description => "Description",
        :publisher => "Publisher",
        :contributor => "Contributor",
        :date => "Date",
        :type => "Type",
        :format => "Format",
        :identifier => "Identifier",
        :source => "Source",
        :language => "Language",
        :relation => "Relation",
        :coverage => "Coverage",
        :rights => "Rights"
      )
    ])
  end

  it "renders a list of oai_recs" do
    render
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Creator".to_s, :count => 2
    assert_select "tr>td", :text => "Subject".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => "Publisher".to_s, :count => 2
    assert_select "tr>td", :text => "Contributor".to_s, :count => 2
    assert_select "tr>td", :text => "Date".to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => "Format".to_s, :count => 2
    assert_select "tr>td", :text => "Identifier".to_s, :count => 2
    assert_select "tr>td", :text => "Source".to_s, :count => 2
    assert_select "tr>td", :text => "Language".to_s, :count => 2
    assert_select "tr>td", :text => "Relation".to_s, :count => 2
    assert_select "tr>td", :text => "Coverage".to_s, :count => 2
    assert_select "tr>td", :text => "Rights".to_s, :count => 2
  end
end
