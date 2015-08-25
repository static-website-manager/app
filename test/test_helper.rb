ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  private

  def authorization
    authorizations(:sample_website_user_one_full_access)
  end

  def authorization_unconfirmed
    authorizations(:sample_website_user_unconfirmed_full_access)
  end

  def sign_in(user)
    post_via_redirect '/sign-in', email: user.email, password: 'password'
  end

  def user
    users(:user_one)
  end

  def user_unconfirmed
    users(:user_unconfirmed)
  end

  def website
    websites(:sample_website)
  end

  def website_new
    websites(:new_website)
  end
end
