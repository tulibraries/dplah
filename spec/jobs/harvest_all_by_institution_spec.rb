require 'rails_helper'

RSpec.describe HarvestAllByInstitution, type: :job do
  it "adds Harvest.perform to the Harvest queue" do
    provider = FactoryGirl.create(:provider_small_collection).attributes
    provider_obj = Provider.find(provider["id"])
    allow(HarvestUtils).to receive(:harvest_action_all).with(provider_obj) {1}
    expect(HarvestAllByInstitution.perform(provider)).to eq 1
  end
end
