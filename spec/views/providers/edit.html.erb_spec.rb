require 'rails_helper'

RSpec.describe "providers/edit", :type => :view do
  before(:each) do
    @provider = assign(:provider, Provider.create!(
      :name => "MyString",
      :description => "MyText",
      :endpoint_url => "http://example.com",
      :metadata_prefix => "MyString",
      :set => "MyString"
    ))
  end

  it "renders the edit provider form" do
    render

    assert_select "form[action=?][method=?]", provider_path(@provider), "post" do

      assert_select "input#provider_name[name=?]", "provider[name]"

      assert_select "textarea#provider_description[name=?]", "provider[description]"

      assert_select "input#provider_endpoint_url[name=?]", "provider[endpoint_url]"

      assert_select "input#provider_metadata_prefix[name=?]", "provider[metadata_prefix]"

      assert_select "input#provider_set[name=?]", "provider[set]"
    end
  end
end
