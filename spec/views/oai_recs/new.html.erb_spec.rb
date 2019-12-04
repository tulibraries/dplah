require 'rails_helper'

RSpec.describe "oai_recs/new", :type => :view do

  skip "Travis-CI Fail: 503 Service Unavailable" do
  let (:item_record) { FactoryBot.create(:oai_rec) }

  before(:each) do
    oai_rec = FactoryBot.create(:oai_rec)
    assign(:oai_rec, OaiRec.new(
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
    ))
  end

  it "renders new oai_rec form" do
    render

    assert_select "form[action=?][method=?]", oai_recs_path, "post" do

      assert_select "input#oai_rec_title[name=?]", "oai_rec[title]"

      assert_select "input#oai_rec_creator[name=?]", "oai_rec[creator]"

      assert_select "input#oai_rec_subject[name=?]", "oai_rec[subject]"

      assert_select "input#oai_rec_description[name=?]", "oai_rec[description]"

      assert_select "input#oai_rec_publisher[name=?]", "oai_rec[publisher]"

      assert_select "input#oai_rec_contributor[name=?]", "oai_rec[contributor]"

      assert_select "input#oai_rec_date[name=?]", "oai_rec[date]"

      assert_select "input#oai_rec_type[name=?]", "oai_rec[type]"

      assert_select "input#oai_rec_format[name=?]", "oai_rec[format]"

      assert_select "input#oai_rec_identifier[name=?]", "oai_rec[identifier]"

      assert_select "input#oai_rec_source[name=?]", "oai_rec[source]"

      assert_select "input#oai_rec_language[name=?]", "oai_rec[language]"

      assert_select "input#oai_rec_relation[name=?]", "oai_rec[relation]"

      assert_select "input#oai_rec_coverage[name=?]", "oai_rec[coverage]"

      assert_select "input#oai_rec_rights[name=?]", "oai_rec[rights]"
    end
  end
  end # Skip
end
