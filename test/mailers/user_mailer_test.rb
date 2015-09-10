require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  def test_subscription_confirmation
    user = User.first
    email = UserMailer.subscription_confirmation(user).deliver_now
    refute ActionMailer::Base.deliveries.empty?
    assert_equal ['support@staticwebsitemanager.test'], email.from
    assert_equal [user.email], email.to
  end
end
