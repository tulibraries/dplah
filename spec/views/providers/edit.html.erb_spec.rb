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

      assert_select "select#provider_endpoint_url[name=?]", "provider[endpoint_url]"

      assert_select "input#provider_set[name=?]", "provider[set]"

      assert_select "input#provider_collection_name[name=?]", "provider[collection_name]"

      assert_select "select#provider_contributing_institution[name=?]", "provider[contributing_institution]"
      
      assert_select "select#provider_intermediate_provider[name=?]", "provider[intermediate_provider]"

      assert_select "select#provider_provider_id_prefix[name=?]", "provider[provider_id_prefix]"

      assert_select "select#provider_email[name=?]", "provider[email]"

      assert_select "select#provider_in_production[name=?]", "provider[in_production]"

      assert_select "select#provider_common_repository_type[name=?]", "provider[common_repository_type]"
    end
  end
end
