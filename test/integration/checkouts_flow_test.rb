require 'test_helper'

class CheckoutsFlowTest < ActionDispatch::IntegrationTest
  def test_new
    sign_in user
    get new_website_checkout_path(website)
    assert_response 200
  end

  def test_failed_create
    sign_in user
    post_via_redirect website_checkouts_path(website, invalid_params)
    assert_response 422
    assert_equal new_website_checkout_path(website), path
  end

  def test_successful_create
    sign_in user
    post_via_redirect website_checkouts_path(website, valid_params)
    assert_response 200
    assert_equal website_branch_path(website, 'test'), path
  end

  private

  def invalid_params
    {
      checkout: {
        source: 'asdf',
        target: 'master',
      }
    }
  end

  def valid_params
    {
      checkout: {
        source: 'master',
        target: 'test',
      }
    }
  end
end
