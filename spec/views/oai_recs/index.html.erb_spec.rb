require 'rails_helper'

RSpec.describe "oai_recs/index", :type => :view do

  let (:item_record) { FactoryGirl.create(:oai_rec) }

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
    assert_select "tr>td", :text => "[&quot;#{item_record[:title].first}&quot;]".to_s, :count => 2
    assert_select "tr>td", :text => "[&quot;#{item_record[:creator].first}&quot;]".to_s, :count => 2
    assert_select "tr>td", :text => "[&quot;#{item_record[:subject].first}&quot;]".to_s, :count => 2
    assert_select "tr>td", :text => "[&quot;#{item_record[:description].first}&quot;]".to_s, :count => 2
    assert_select "tr>td", :text => "[&quot;#{item_record[:publisher].first}&quot;]".to_s, :count => 2
    assert_select "tr>td", :text => "[&quot;#{item_record[:contributor].first}&quot;]".to_s, :count => 2
    assert_select "tr>td", :text => "[&quot;#{item_record[:date].first}&quot;]".to_s, :count => 2
    assert_select "tr>td", :text => "[&quot;#{item_record[:type].first}&quot;]".to_s, :count => 2
    assert_select "tr>td", :text => "[&quot;#{item_record[:format].first}&quot;]".to_s, :count => 2
    assert_select "tr>td", :text => "[&quot;#{item_record[:identifier].first}&quot;]".to_s, :count => 2
    assert_select "tr>td", :text => "[&quot;#{item_record[:source].first}&quot;]".to_s, :count => 2
    assert_select "tr>td", :text => "[&quot;#{item_record[:language].first}&quot;]".to_s, :count => 2
    assert_select "tr>td", :text => "[&quot;#{item_record[:relation].first}&quot;]".to_s, :count => 2
    assert_select "tr>td", :text => "[&quot;#{item_record[:coverage].first}&quot;]".to_s, :count => 2
    assert_select "tr>td", :text => "[&quot;#{item_record[:rights].first}&quot;]".to_s, :count => 2
  end
end
