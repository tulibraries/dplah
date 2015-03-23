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
  
  it "should deliver a dumped whole index email" do
    mail = HarvestMailer.dumped_whole_index_email
    expect(ActionMailer::Base.deliveries.size).to eq 1  
    expect(mail.to).to include(HarvestMailer.default[:to])
    expect(mail.subject).to match /Whole Index Deleted/
  end
  
  it "should deliver a successful dump and reindex by institution email" do
    mail = HarvestMailer.dump_and_reindex_by_institution_email(provider)
    expect(ActionMailer::Base.deliveries.size).to eq 1  
    expect(mail.to).to include(provider.email)
    expect(mail.subject).to match /Dumped and reindexed #{provider.name} collection/
  end
  
  it "should deliver a successful dump and reindex by collection email" do
    mail = HarvestMailer.dump_and_reindex_by_collection_email(provider)
    expect(ActionMailer::Base.deliveries.size).to eq 1  
    expect(mail.to).to include(provider.email)
    expect(mail.subject).to match /Dumped and reindexed the #{provider.set} collection/
  end
end
