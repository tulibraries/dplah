require "rails_helper"

RSpec.describe BasicMailer, type: :mailer do

  def html_part_of(mail)
    mail.parts.detect{|p| p.content_type.match(/text\/html/)}
  end

  let(:provider) { FactoryBot.build(:provider_small_collection) }
  let(:logfile) { File.expand_path(File.join(Rails.root, "spec", "fixtures", "log", "harvest_log.txt")) }
  let(:config) { YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__)) }

  before :each do
    ActionMailer::Base.deliveries = []
  end

  it "is expected to use the default email recepient and sender" do
    expect(BasicMailer.default[:from]).to eq config['email_sender']
    expect(BasicMailer.default[:to]).to eq config['email_recipient']
  end

  it "should deliver a basic error message by email" do
    error_message = "ERROR 404: Unknown"
    mail = BasicMailer.error_message_email(provider, error_message, logfile).deliver
    expect(ActionMailer::Base.deliveries.size).to eq 1
    expect(mail.to).to include(provider.email)
    expect(mail.subject).to match I18n.t 'dpla.basic_mailer.error_occured'
    expect(html_part_of(mail).body.raw_source).to match error_message
    expect(mail.attachments.first.filename).to eq File.basename(logfile)
  end
end
