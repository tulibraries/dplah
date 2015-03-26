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

    it "Harvests all of the data from all providers" do
      expect(ActiveFedora::Base.count).to eq 0
      sso = stdout_to_null
      VCR.use_cassette "application_controller/multiple_providers" do
        post :harvest_all_providers, valid_session
      end
      $stdout = sso
      expect(ActiveFedora::Base.count).to eq 12 
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

    it "deletes the index" do
      expect(ActiveFedora::Base.count).to eq 12
      post :dump_whole_index, valid_session
      expect(ActiveFedora::Base.count).to eq 0
      expect(response).to redirect_to(providers_url)
    end
  end

end
