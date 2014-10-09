require 'rails_helper'

RSpec.describe "providers/new", :type => :view do
  before(:each) do
    assign(:provider, Provider.new(
      :name => "MyString",
      :description => "MyText",
      :endpoint_url => "MyString",
      :metadata_prefix => "MyString",
      :set => "MyString"
    ))
  end

  it "renders new provider form" do
    render

    assert_select "form[action=?][method=?]", providers_path, "post" do

      assert_select "input#provider_name[name=?]", "provider[name]"

      assert_select "textarea#provider_description[name=?]", "provider[description]"

      assert_select "input#provider_endpoint_url[name=?]", "provider[endpoint_url]"

      assert_select "input#provider_metadata_prefix[name=?]", "provider[metadata_prefix]"

      assert_select "input#provider_set[name=?]", "provider[set]"
    end
  end
end
