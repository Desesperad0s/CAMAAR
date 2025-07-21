class ApplicationMailer < ActionMailer::Base
  default from: "lucaslgol05@gmail.com"  # Email da conta SendGrid
  layout "mailer"
end
