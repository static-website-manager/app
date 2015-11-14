class UserMailer < ApplicationMailer
  def authorization_invitation(authorization)
    @user = authorization.user
    @website = authorization.website
    mail to: @user.email, subject: "You have been invited to manage “#{@website.name}”"
  end

  def email_confirmation(user)
    @user = user
    mail to: (user.pending_email? ? user.pending_email : user.email), subject: 'Please Confirm Your Email Address'
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

  def subscription_update_confirmation(website)
    @website = website
    mail to: website.account_owners.map(&:email), subject: 'Your Website Subscription Was Changed'
  end
end
