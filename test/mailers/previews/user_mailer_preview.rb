class UserMailerPreview < ActionMailer::Preview
  def test_subscription_confirmation
    UserMailer.subscription_confirmation(User.first)
  end
end
