require 'rails_helper'

RSpec.describe "providers/show", :type => :view do
  before(:each) do
    @provider = assign(:provider, Provider.create!(
      :name => "Name",
      :description => "MyText",
      :endpoint_url => "Endpoint Url",
      :metadata_prefix => "Metadata Prefix",
      :set => "Set"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Endpoint Url/)
    expect(rendered).to match(/Metadata Prefix/)
    expect(rendered).to match(/Set/)
  end
end
