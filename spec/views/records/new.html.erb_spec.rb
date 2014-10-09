require 'rails_helper'

RSpec.describe "records/new", :type => :view do
  before(:each) do
    assign(:record, Record.new(
      :content => "MyText",
      :provider => nil
    ))
  end

  it "renders new record form" do
    render

    assert_select "form[action=?][method=?]", records_path, "post" do

      assert_select "textarea#record_content[name=?]", "record[content]"

      assert_select "input#record_provider_id[name=?]", "record[provider_id]"
    end
  end
end
