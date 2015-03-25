class HarvestMailer < ActionMailer::Base
  config = YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__))
  default from: config['email_sender'],
          to: config['email_recipient']

  def harvest_complete_email(provider, logfile)
    @provider = provider
    attachments[File.basename(logfile)] = File.read(logfile)
    subject_text = "Harvest of #{provider.set} Completed"
    m = mail(:to=> provider.email, :subject => subject_text)
  end

  def dumped_whole_index_email(logfile)
    attachments[File.basename(logfile)] = File.read(logfile)
    subject_text = "Whole Index Deleted"
    m = mail(subject: subject_text)
  end

  def dump_and_reindex_by_institution_email(provider, logfile)
    @provider = provider
    attachments[File.basename(logfile)] = File.read(logfile)
    subject_text = "Dumped and reindexed #{provider.name} collections"
    m = mail(to: provider.email, subject: subject_text)
  end

  def dump_and_reindex_by_collection_email(provider, logfile)
    @provider = provider
    attachments[File.basename(logfile)] = File.read(logfile)
    subject_text = "Dumped and reindexed the #{provider.set} collection"
    m = mail(to: provider.email, subject: subject_text)
  end
end
