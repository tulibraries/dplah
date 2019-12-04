require 'rails_helper'

RSpec.describe HarvestAllByInstitution, type: :job do
  xit "adds Harvest.perform to the Harvest queue" do
    provider = FactoryBot.create(:provider_small_collection).attributes
    provider_obj = Provider.find(provider["id"])
    allow(HarvestUtils).to receive(:harvest_all_selective).with(provider_obj) {1}
    expect(HarvestAllByInstitution.perform(provider)).to eq 1
  end
end
