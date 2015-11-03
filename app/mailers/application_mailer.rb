class ApplicationMailer < ActionMailer::Base
  default from: "support@#{ENV['HOST']}"
end
