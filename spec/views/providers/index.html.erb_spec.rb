require 'rails_helper'

RSpec.describe "providers/index", :type => :view do
  before(:each) do
    assign(:providers, [
      Provider.create!(
        :name => "Name",
        :description => "MyText",
        :endpoint_url => "Endpoint Url",
        :metadata_prefix => "Metadata Prefix",
        :set => "Set"
      ),
      Provider.create!(
        :name => "Name",
        :description => "MyText",
        :endpoint_url => "Endpoint Url",
        :metadata_prefix => "Metadata Prefix",
        :set => "Set"
      )
    ])
  end

  it "renders a list of providers" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Endpoint Url".to_s, :count => 2
    assert_select "tr>td", :text => "Metadata Prefix".to_s, :count => 2
    assert_select "tr>td", :text => "Set".to_s, :count => 2
  end
end
