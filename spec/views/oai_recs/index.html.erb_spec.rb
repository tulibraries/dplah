require 'rails_helper'

RSpec.describe "oai_recs/index", :type => :view do

  skip "Travis-CI Fail: 503 Service Unavailable" do
  let (:item_record) { FactoryBot.create(:oai_rec) }

  before(:each) do
    assign(:oai_recs, [
      OaiRec.create!(
        :title => item_record[:title],
        :creator => item_record[:creator],
        :subject => item_record[:subject],
        :description => item_record[:description],
        :publisher => item_record[:publisher],
        :contributor => item_record[:contributor],
        :date => item_record[:date],
        :type => item_record[:type],
        :format => item_record[:format],
        :identifier => item_record[:identifier],
        :source => item_record[:source],
        :language => item_record[:language],
        :relation => item_record[:relation],
        :coverage => item_record[:coverage],
        :rights => item_record[:rights]
      ),
      OaiRec.create!(
        :title => item_record[:title],
        :creator => item_record[:creator],
        :subject => item_record[:subject],
        :description => item_record[:description],
        :publisher => item_record[:publisher],
        :contributor => item_record[:contributor],
        :date => item_record[:date],
        :type => item_record[:type],
        :format => item_record[:format],
        :identifier => item_record[:identifier],
        :source => item_record[:source],
        :language => item_record[:language],
        :relation => item_record[:relation],
        :coverage => item_record[:coverage],
        :rights => item_record[:rights]
      )
    ])
  end

  it "renders a list of oai_recs" do
    render
    assert_select "tr>td", :text => "[\"#{item_record[:title].first}\"]".to_s, :count => 2
    assert_select "tr>td", :text => "[\"#{item_record[:creator].first}\"]".to_s, :count => 2
    assert_select "tr>td", :text => "[\"#{item_record[:subject].first}\"]".to_s, :count => 2
    assert_select "tr>td", :text => "[\"#{item_record[:description].first}\"]".to_s, :count => 2
    assert_select "tr>td", :text => "[\"#{item_record[:publisher].first}\"]".to_s, :count => 2
    assert_select "tr>td", :text => "[\"#{item_record[:contributor].first}\"]".to_s, :count => 2
    assert_select "tr>td", :text => "[\"#{item_record[:date].first}\"]".to_s, :count => 2
    assert_select "tr>td", :text => "[\"#{item_record[:type].first}\"]".to_s, :count => 2
    assert_select "tr>td", :text => "[\"#{item_record[:format].first}\"]".to_s, :count => 2
    assert_select "tr>td", :text => "[\"#{item_record[:identifier].first}\"]".to_s, :count => 2
    assert_select "tr>td", :text => "[\"#{item_record[:source].first}\"]".to_s, :count => 2
    assert_select "tr>td", :text => "[\"#{item_record[:language].first}\"]".to_s, :count => 2
    assert_select "tr>td", :text => "[\"#{item_record[:relation].first}\"]".to_s, :count => 2
    assert_select "tr>td", :text => "[\"#{item_record[:coverage].first}\"]".to_s, :count => 2
    assert_select "tr>td", :text => "[\"#{item_record[:rights].first}\"]".to_s, :count => 2
  end
  end # Skip
end
