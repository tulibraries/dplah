require 'rails_helper'

RSpec.describe "providers/show", :type => :view do
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

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/http:\/\/example.com/)
    expect(rendered).to match(/Set/)
    expect(rendered).to match(/Collection/)
    expect(rendered).to match(/Contributor/)
    expect(rendered).to match(/NO/)
  end
end
