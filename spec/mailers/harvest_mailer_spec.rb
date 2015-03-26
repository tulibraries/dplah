require "rails_helper"

RSpec.describe HarvestMailer, type: :mailer do

  def html_part_of(mail)
    mail.parts.detect{|p| p.content_type.match(/text\/html/)}
  end

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
    mail = HarvestMailer.harvest_complete_email(provider, logfile).deliver
    expect(ActionMailer::Base.deliveries.size).to eq 1  
    expect(mail.to).to include(provider.email)
    expect(mail.subject).to match I18n.t 'dpla.harvest_mailer.harvest_subject'
    expect(html_part_of(mail).body.raw_source).to include(I18n.t 'dpla.harvest_mailer.harvest_complete_text')
    expect(mail.attachments.first.filename).to eq File.basename(logfile)
  end
  
  it "is expected to deliver Deleted all from Aggregator Index email" do
    mail = HarvestMailer.dumped_whole_index_email(logfile).deliver
    expect(ActionMailer::Base.deliveries.size).to eq 1  
    expect(mail.to).to include(HarvestMailer.default[:to])
    expect(mail.subject).to match I18n.t('dpla.harvest_mailer.dump_whole_index_subject')
    expect(html_part_of(mail).body.raw_source).to include(I18n.t 'dpla.harvest_mailer.dumped_whole_index_text')
    expect(mail.attachments.first.filename).to eq File.basename(logfile)
  end
  
  it "should deliver a successful dump and reindex by institution email" do
    mail = HarvestMailer.dump_and_reindex_by_institution_email(provider, logfile).deliver
    expect(ActionMailer::Base.deliveries.size).to eq 1  
    expect(mail.to).to include(provider.email)
    expect(mail.subject).to match I18n.t('dpla.harvest_mailer.dump_and_reindex_subject')
    expect(html_part_of(mail).body.raw_source).to include(provider.name)
    expect(mail.attachments.first.filename).to eq File.basename(logfile)
  end
  
  it "should deliver a successful dump and reindex by collection email" do
    mail = HarvestMailer.dump_and_reindex_by_collection_email(provider, logfile).deliver
    expect(ActionMailer::Base.deliveries.size).to eq 1  
    expect(mail.to).to include(provider.email)
    expect(mail.subject).to match I18n.t('dpla.harvest_mailer.dump_and_reindex_subject')
    expect(html_part_of(mail).body.raw_source).to include(provider.collection_name)
    expect(mail.attachments.first.filename).to eq File.basename(logfile)
  end
end
