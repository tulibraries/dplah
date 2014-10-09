require 'rails_helper'

RSpec.describe "oai_recs/edit", :type => :view do
  before(:each) do
    @oai_rec = assign(:oai_rec, OaiRec.create!(
      :title => "MyString",
      :creator => "MyString",
      :subject => "MyString",
      :description => "MyString",
      :publisher => "MyString",
      :contributor => "MyString",
      :date => "MyString",
      :type => "",
      :format => "MyString",
      :identifier => "MyString",
      :source => "MyString",
      :language => "MyString",
      :relation => "MyString",
      :coverage => "MyString",
      :rights => "MyString"
    ))
  end

  it "renders the edit oai_rec form" do
    render

    assert_select "form[action=?][method=?]", oai_rec_path(@oai_rec), "post" do

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
end
