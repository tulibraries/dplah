class HarvestMailer < ActionMailer::Base
  default from: "from@example.com",
          to: "dplah@example.edu"

  def harvest_complete_email(provider)
    @provider = provider
    subject_text = "Harvest of #{provider.set} Completed"
    m = mail(to: provider.email, subject: subject_text).deliver
  end

  def conversion_complete_email(provider)
    @provider = provider
    subject_text = "Conversion of #{provider.set} Completed"
    m = mail(to: provider.email, subject: subject_text).deliver
  end

  def ingest_complete_email(provider)
    @provider = provider
    subject_text = "Ingest of #{provider.set} Completed"
    m = mail(to: provider.email, subject: subject_text).deliver
  end
end
