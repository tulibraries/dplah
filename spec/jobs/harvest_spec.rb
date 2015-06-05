require 'rails_helper'

RSpec.describe Harvest, type: :job do
  before do
    ResqueSpec.reset!
  end

  xit "adds Harvest.perform to the Harvest queue" do
    provider = FactoryGirl.create(:provider_small_collection).attributes
    provider_obj = Provider.find(provider["id"])
    allow(HarvestUtils).to receive(:harvest_action).with(provider_obj) {1}
    allow(Resque).to receive(:enqueue).with(Harvest, provider)
    Harvest.perform(provider)
    expect(Harvest).to have_queue_size_of(1)
  end
end
