require "rails_helper"

RSpec.describe HarvestMailer, type: :mailer do
  let(:provider) { FactoryGirl.build(:provider_small_collection) }
  
  before :each do
    ActionMailer::Base.deliveries = []
  end
  
  it "should deliver a successful harvest email" do
    mail = HarvestMailer.harvest_complete_email(provider)
    expect(ActionMailer::Base.deliveries.size).to eq 1  
    expect(mail.to).to include(provider.email)
    expect(mail.subject).to match /Harvest of #{provider.set} Completed/
  end

  it "should deliver a successful conversion email" do
    mail = HarvestMailer.conversion_complete_email(provider)
    expect(ActionMailer::Base.deliveries.size).to eq 1  
    expect(mail.to).to include(provider.email)
    expect(mail.subject).to match /Conversion of #{provider.set} Completed/
  end

  it "should deliver a successful ingest eamil" do
    mail = HarvestMailer.ingest_complete_email(provider)
    expect(ActionMailer::Base.deliveries.size).to eq 1  
    expect(mail.to).to include(provider.email)
    expect(mail.subject).to match /Ingest of #{provider.set} Completed/
  end
end
