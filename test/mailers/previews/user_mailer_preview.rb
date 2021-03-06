class UserMailerPreview < ActionMailer::Preview
  def authorization_invitation
    UserMailer.authorization_invitation(Authorization.first)
  end

  def email_confirmation
    UserMailer.email_confirmation(User.first)
  end

  def password_reset
    UserMailer.password_reset(User.first)
  end

  def password_update_confirmation
    UserMailer.password_update_confirmation(User.first)
  end

  def subscription_confirmation
    UserMailer.subscription_confirmation(User.first)
  end

  def subscription_update_confirmation
    UserMailer.subscription_update_confirmation(Website.first)
  end
end
