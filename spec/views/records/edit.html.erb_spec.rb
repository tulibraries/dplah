require 'rails_helper'

RSpec.describe "records/edit", :type => :view do
  before(:each) do
    @record = assign(:record, Record.create!(
      :content => "MyText",
      :provider => nil
    ))
  end

  it "renders the edit record form" do
    render

    assert_select "form[action=?][method=?]", record_path(@record), "post" do

      assert_select "textarea#record_content[name=?]", "record[content]"

      assert_select "input#record_provider_id[name=?]", "record[provider_id]"
    end
  end
end
