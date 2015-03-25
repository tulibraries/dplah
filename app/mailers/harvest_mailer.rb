class HarvestMailer < ActionMailer::Base
  config = YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__))
  default from: config['email_sender'],
          to: config['email_recipient']

  def harvest_complete_email(provider, logfile)
    @provider = provider
    attachments[File.basename(logfile)] = File.read(logfile)
    subject_text = I18n.t('dpla.harvest_mailer.harvest_subject')
    m = mail(:to=> provider.email, :subject => subject_text)
  end

  def dumped_whole_index_email(logfile)
    attachments[File.basename(logfile)] = File.read(logfile)
    subject_text = I18n.t('dpla.harvest_mailer.dump_whole_index_subject')
    m = mail(subject: subject_text)
  end

  def dump_and_reindex_by_institution_email(provider, logfile)
    @provider = provider
    attachments[File.basename(logfile)] = File.read(logfile)
    subject_text = I18n.t('dpla.harvest_mailer.dump_and_reindex_subject')
    m = mail(to: provider.email, subject: subject_text)
  end

  def dump_and_reindex_by_collection_email(provider, logfile)
    @provider = provider
    attachments[File.basename(logfile)] = File.read(logfile)
    subject_text = I18n.t('dpla.harvest_mailer.dump_and_reindex_subject')
    m = mail(to: provider.email, subject: subject_text)
  end
end
