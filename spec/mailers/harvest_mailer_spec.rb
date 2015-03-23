require "rails_helper"

RSpec.describe HarvestMailer, type: :mailer do
  let(:provider) { FactoryGirl.build(:provider_small_collection) }
  let(:logfile) { File.expand_path(File.join(Rails.root, "spec", "fixtures", "log", "harvest_log.txt")) }
  
  before :each do
    ActionMailer::Base.deliveries = []
  end
  
  it "should deliver a successful harvest email" do
    mail = HarvestMailer.harvest_complete_email(provider, logfile)
    expect(ActionMailer::Base.deliveries.size).to eq 1  
    expect(mail.to).to include(provider.email)
    expect(mail.subject).to match /Harvest of #{provider.set} Completed/
    expect(mail.attachments.first.filename).to eq File.basename(logfile)
  end
end
