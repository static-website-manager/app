class ApplicationMailer < ActionMailer::Base
  default from: "support@#{Rails.application.secrets.host}"
end
