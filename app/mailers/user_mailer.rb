class UserMailer < ApplicationMailer
  def subscription_confirmation(user)
    mail to: user.email, subject: 'Thanks For Starting Your Trial Subscription'
  end
end
