require 'rails_helper'

RSpec.describe "providers/edit", :type => :view do
  before(:each) do
    @provider = assign(:provider, Provider.create!(
      :name => "Name",
      :endpoint_url => "http://example.com",
      :set => "Set",
      :collection_name => "Collection",
      :contributing_institution => "Contributor",
      :in_production => "NO"
    ))
  end

  it "renders the edit provider form" do
    render

    assert_select "form[action=?][method=?]", provider_path(@provider), "post" do

      assert_select "input#provider_name[name=?]", "provider[name]"

      assert_select "input#provider_endpoint_url[name=?]", "provider[endpoint_url]"

      assert_select "input#provider_set[name=?]", "provider[set]"

      assert_select "input#provider_collection_name[name=?]", "provider[collection_name]"

      pending "Assert on multiselect options"

      assert_select "option provider_contributing_institution[name=?]", "provider[contributing_institution]"

      assert_select "input#provider_in_production[name=?]", "provider[in_production]"
    end
  end
end
