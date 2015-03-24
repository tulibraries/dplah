require "rails_helper"

RSpec.describe HarvestMailer, type: :mailer do
  let(:provider) { FactoryGirl.build(:provider_small_collection) }
  let(:logfile) { File.expand_path(File.join(Rails.root, "spec", "fixtures", "log", "harvest_log.txt")) }
  let(:config) { YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__)) }
  
  before :each do
    ActionMailer::Base.deliveries = []
  end

  it "is expected to use the default email recepient and sender" do
    expect(HarvestMailer.default[:from]).to eq config['email_sender']
    expect(HarvestMailer.default[:to]).to eq config['email_recipient']
  end
  
  it "is expected to deliver harvested all OAI seeds email" do
    mail = HarvestMailer.harvest_complete_email(provider, logfile)
    expect(ActionMailer::Base.deliveries.size).to eq 1  
    expect(mail.to).to include(provider.email)
    expect(mail.subject).to match /Harvest of #{provider.set} Completed/
    expect(mail.attachments.first.filename).to eq File.basename(logfile)
  end
  
  it "is expected to deliver Deleted all from Aggregator Index email" do
    mail = HarvestMailer.dumped_whole_index_email
    expect(ActionMailer::Base.deliveries.size).to eq 1  
    expect(mail.to).to include(HarvestMailer.default[:to])
    expect(mail.subject).to match /Whole Index Deleted/
    expect(mail.body.raw_source).to include(I18n.t 'dpla.harvest_mailer.dumped_whole_index_text')
  end
  
  it "should deliver a successful dump and reindex by institution email" do
    mail = HarvestMailer.dump_and_reindex_by_institution_email(provider)
    expect(ActionMailer::Base.deliveries.size).to eq 1  
    expect(mail.to).to include(provider.email)
    expect(mail.subject).to match /Dumped and reindexed #{provider.name} collection/
    expect(mail.body.raw_source).to include(provider.name)
  end
  
  it "should deliver a successful dump and reindex by collection email" do
    mail = HarvestMailer.dump_and_reindex_by_collection_email(provider)
    expect(ActionMailer::Base.deliveries.size).to eq 1  
    expect(mail.to).to include(provider.email)
    expect(mail.subject).to match /Dumped and reindexed the #{provider.set} collection/
    expect(mail.body.raw_source).to include(provider.collection_name)
  end
end
