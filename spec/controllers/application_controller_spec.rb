require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  let(:provider1) {
   FactoryGirl.build(:multiple_providers).attributes
  }
  let(:provider2) {
   FactoryGirl.build(:multiple_providers).attributes
  }

  let(:valid_session) { {} }

  describe "Harvest all providers" do
    before (:each) do
      # Clean out all records
      ActiveFedora::Base.destroy_all
      # Create initial provider
      Provider.create! provider1
      Provider.create! provider2
    end

    xit "Harvests all of the data from all providers" do
      expect(HarvestAll).to have_queue_size_of(0)
      sso = stdout_to_null
      VCR.use_cassette "application_controller/multiple_providers" do
        post :harvest_all_providers, valid_session
      end
      $stdout = sso
      expect(HarvestAll).to have_queue_size_of(1)
      expect(response).to redirect_to(providers_url)
    end
  end

  describe "Dump whole index" do
    before (:each) do
      # Clean out all records
      ActiveFedora::Base.destroy_all
      # Create initial provider
      Provider.create! provider1
      Provider.create! provider2
      # Harvest data
      sso = stdout_to_null
      VCR.use_cassette "application_controller/multiple_providers" do
        post :harvest_all_providers, valid_session
      end
      $stdout = sso
    end

    after (:each) do
      # Clean out all records
      ActiveFedora::Base.destroy_all
    end

    xit "deletes the index" do
      expect(DumpWholeIndex).to have_queue_size_of(0)
      post :dump_whole_index, valid_session
      expect(DumpWholeIndex).to have_queue_size_of(1)
      expect(response).to redirect_to(providers_url)
    end
  end

end
