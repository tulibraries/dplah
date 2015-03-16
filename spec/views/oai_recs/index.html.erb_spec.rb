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
    assert_select "tr>td", :text => '[&quot;Title&quot;]'.to_s, :count => 2
    assert_select "tr>td", :text => '[&quot;Creator&quot;]'.to_s, :count => 2
    assert_select "tr>td", :text => '[&quot;Subject&quot;]'.to_s, :count => 2
    assert_select "tr>td", :text => '[&quot;Description&quot;]'.to_s, :count => 2
    assert_select "tr>td", :text => '[&quot;Publisher&quot;]'.to_s, :count => 2
    assert_select "tr>td", :text => '[&quot;Contributor&quot;]'.to_s, :count => 2
    assert_select "tr>td", :text => '[&quot;Date&quot;]'.to_s, :count => 2
    assert_select "tr>td", :text => '[&quot;Type&quot;]'.to_s, :count => 2
    assert_select "tr>td", :text => '[&quot;Format&quot;]'.to_s, :count => 2
    assert_select "tr>td", :text => '[&quot;Identifier&quot;]'.to_s, :count => 2
    assert_select "tr>td", :text => '[&quot;Source&quot;]'.to_s, :count => 2
    assert_select "tr>td", :text => '[&quot;Language&quot;]'.to_s, :count => 2
    assert_select "tr>td", :text => '[&quot;Relation&quot;]'.to_s, :count => 2
    assert_select "tr>td", :text => '[&quot;Coverage&quot;]'.to_s, :count => 2
    assert_select "tr>td", :text => '[&quot;Rights&quot;]'.to_s, :count => 2
  end
end
