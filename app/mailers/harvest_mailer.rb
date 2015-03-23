class HarvestMailer < ActionMailer::Base
  default from: "from@example.com",
          to: "dplah@example.edu"

  def harvest_complete_email(provider, logfile)
    @provider = provider
    attachments[File.basename(logfile)] = File.read(logfile)
    subject_text = "Harvest of #{provider.set} Completed"
    m = mail(to: provider.email, subject: subject_text).deliver
  end
end
