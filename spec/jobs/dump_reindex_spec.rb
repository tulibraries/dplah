require 'rails_helper'

RSpec.describe DumpReindex, type: :job do
  before :each do
    ResqueSpec.reset!
  end

  xit "adds DumpReindex.perform to the DumpReindex queue" do
    provider = FactoryGirl.create(:provider_small_collection).attributes
    provider_obj = Provider.find(provider["id"])
    option = "institution"
    DumpReindex.perform(provider_obj, option)
    expect(DumpReindex).to have_queue_size_of(1)
  end
end
