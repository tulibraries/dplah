class BasicMailer < ActionMailer::Base
  config = YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__))
  default from: config['email_sender'],
          to: config['email_recipient']

  def error_message_email(provider, error_message, logfile)
    @provider = provider
    @error_message = error_message
    attachments[File.basename(logfile)] = File.read(logfile)
    subject_text = I18n.t('dpla.basic_mailer.error_occured')
    m = mail(:to=> provider.email, :subject => subject_text)
  end

end
