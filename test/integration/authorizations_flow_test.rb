require 'test_helper'

class AuthorizationsFlowTest < ActionDispatch::IntegrationTest
  def test_authorizations
    sign_in user
    get website_authorizations_path(website)
    assert_response 200
    assert_select "a[href=\"#{new_website_authorization_path(website)}\"]"
  end

  def test_new_authorization
    sign_in user
    get new_website_authorization_path(website)
    assert_response 200
  end

  def test_failed_create_authorization
    sign_in user
    assert_no_difference 'Authorization.count' do
      post_via_redirect website_authorizations_path(website), invalid_params
    end
    assert_response 422
    assert_equal website_authorizations_path(website), path
  end

  def test_successful_create_authorization
    sign_in user
    assert_difference 'Authorization.count' do
      post_via_redirect website_authorizations_path(website), valid_params
    end
    assert_response 200
    assert_equal website_authorizations_path(website), path
  end

  def test_edit_authorization
    sign_in user
    get edit_website_authorization_path(website, authorization)
    assert_response 200
  end

  def test_failed_update_authorization
    sign_in user
    patch_via_redirect website_authorization_path(website, authorization), invalid_params
    assert_response 422
    assert_equal website_authorization_path(website, authorization), path
  end

  def test_successful_update_authorization
    sign_in user
    patch_via_redirect website_authorization_path(website, authorization), valid_params
    assert_response 200
    assert_equal website_authorizations_path(website), path
  end

  def test_destroy_own_authorization
    sign_in user
    assert_no_difference 'Authorization.count' do
      delete_via_redirect website_authorization_path(website, authorization)
    end
    assert_response 200
    assert_equal website_authorizations_path(website), path
  end

  def test_destroy_authorization
    sign_in user
    assert_difference 'Authorization.count', -1 do
      delete_via_redirect website_authorization_path(website, authorization_unconfirmed)
    end
    assert_response 200
    assert_equal website_authorizations_path(website), path
  end

  private

  def valid_params
    {
      authorization: {
        role: 'full_access',
        user_attributes: {
          name: 'Test',
          email: 'test@test.local',
        },
      },
    }
  end

  def invalid_params
    { authorization: { role: '' }}
  end
end
