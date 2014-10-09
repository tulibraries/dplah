require 'rails_helper'

RSpec.describe "records/index", :type => :view do
  before(:each) do
    assign(:records, [
      Record.create!(
        :content => "MyText",
        :provider => nil
      ),
      Record.create!(
        :content => "MyText",
        :provider => nil
      )
    ])
  end

  it "renders a list of records" do
    render
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
