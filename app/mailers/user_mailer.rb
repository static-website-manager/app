class UserMailer < ApplicationMailer
  def email_confirmation(user)
    @user = user
    mail to: user.email, subject: 'Please Confirm Your Email Address'
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: 'Reset Your Password'
  end

  def password_update_confirmation(user)
    mail to: user.email, subject: 'Your Password Was Changed'
  end

  def subscription_confirmation(user)
    @user = user
    mail to: user.email, subject: 'Thanks For Starting Your Trial Subscription'
  end
end
