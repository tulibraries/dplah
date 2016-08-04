class HarvestMailer < ActionMailer::Base
  config = YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__))
  default from: config['email_sender'],
          to: config['email_recipient']

  def define_headers(subject_text, provider=nil)
    headers = {subject: subject_text}
    headers.merge({to: provider.email}) if provider && provider.email
    headers
  end

  def harvest_complete_email(provider, logfile)
    attachments[File.basename(logfile)] = File.read(logfile)
    subject_text = I18n.t('dpla.harvest_mailer.harvest_subject')
    headers = define_headers(subject_text, provider)
    mail(headers)
  end

  def dumped_whole_index_email(logfile)
    attachments[File.basename(logfile)] = File.read(logfile)
    subject_text = I18n.t('dpla.harvest_mailer.dump_whole_index_subject')
    mail(subject: subject_text)
  end

  def dump_and_reindex_by_institution_email(provider, logfile)
    attachments[File.basename(logfile)] = File.read(logfile)
    subject_text = I18n.t('dpla.harvest_mailer.dump_and_reindex_subject')
    headers = define_headers(subject_text, provider)
    mail(headers)
  end

  def dump_and_reindex_by_collection_email(provider, logfile)
    attachments[File.basename(logfile)] = File.read(logfile)
    subject_text = I18n.t('dpla.harvest_mailer.dump_and_reindex_subject')
    headers = define_headers(subject_text, provider)
    mail(headers)
  end
end
