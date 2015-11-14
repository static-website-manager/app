require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  def test_authorization_invitation
    authorization = Authorization.first
    email = UserMailer.authorization_invitation(authorization).deliver_now
    refute ActionMailer::Base.deliveries.empty?
    assert_equal ['support@staticwebsitemanager.test'], email.from
    assert_equal [authorization.user.email], email.to
  end

  def test_email_confirmation
    user = User.first
    email = UserMailer.email_confirmation(user).deliver_now
    refute ActionMailer::Base.deliveries.empty?
    assert_equal ['support@staticwebsitemanager.test'], email.from
    assert_equal [user.email], email.to
  end

  def test_password_reset
    user = User.first
    email = UserMailer.password_reset(user).deliver_now
    refute ActionMailer::Base.deliveries.empty?
    assert_equal ['support@staticwebsitemanager.test'], email.from
    assert_equal [user.email], email.to
  end

  def test_password_update_confirmation
    user = User.first
    email = UserMailer.password_update_confirmation(user).deliver_now
    refute ActionMailer::Base.deliveries.empty?
    assert_equal ['support@staticwebsitemanager.test'], email.from
    assert_equal [user.email], email.to
  end

  def test_subscription_confirmation
    user = User.first
    email = UserMailer.subscription_confirmation(user).deliver_now
    refute ActionMailer::Base.deliveries.empty?
    assert_equal ['support@staticwebsitemanager.test'], email.from
    assert_equal [user.email], email.to
  end

  def test_subscription_update_confirmation
    website = Website.first
    email = UserMailer.subscription_update_confirmation(website).deliver_now
    refute ActionMailer::Base.deliveries.empty?
    assert_equal ['support@staticwebsitemanager.test'], email.from
    assert_equal website.account_owners.map(&:email), email.to
  end
end
