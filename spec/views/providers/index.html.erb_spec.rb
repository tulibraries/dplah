require 'rails_helper'

RSpec.describe "providers/index", :type => :view do
  before(:each) do
    assign(:providers, [
      Provider.create!(
        :name => "Name",
        :endpoint_url => "http://example.com",
        :set => "Set",
        :collection_name => "Collection Name",
        :contributing_institution => "Contributor",
        :in_production => "No"
      ),
      Provider.create!(
        :name => "Name",
        :endpoint_url => "http://example.com",
        :set => "Set",
        :collection_name => "Collection Name",
        :contributing_institution => "Contributor",
        :in_production => "No"
      )
    ])
  end

  it "renders a list of providers" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "http://example.com".to_s, :count => 2
    assert_select "tr>td", :text => "Set".to_s, :count => 2
    assert_select "tr>td", :text => "Collection Name".to_s, :count => 2
    assert_select "tr>td", :text => "Contributor".to_s, :count => 2
    assert_select "tr>td", :text => "No".to_s, :count => 2
  end
end
