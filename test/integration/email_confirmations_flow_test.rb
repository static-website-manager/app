require 'test_helper'

class EmailConfirmationsFlowTest < ActionDispatch::IntegrationTest
  def test_new_email_confirmation
    visit_email_confirmation_page(assert: true)
  end

  def test_failed_new_email_confirmation
    visit_email_confirmation_page
    post_via_redirect email_confirmation_path, invalid_params
    assert_response 422
    assert_equal new_email_confirmation_path, path
  end

  def test_successful_new_email_confirmation
    visit_email_confirmation_page
    post_via_redirect email_confirmation_path, valid_params
    assert_response 200
    assert_equal root_path, path
  end

  def test_failed_email_confirmation
    get_via_redirect email_confirmation_path(token: 'unknown')
    assert_response 200
    assert_equal root_path, path
    refute user_unconfirmed.reload.confirmed?
  end

  def test_successful_email_confirmation
    get_via_redirect email_confirmation_path(token: user_unconfirmed.email_confirmation_token!)
    assert_response 200
    assert_equal websites_path, path
    assert user_unconfirmed.reload.confirmed?
  end

  private

  def invalid_params
    { email: 'invalid@unknown.com' }
  end

  def valid_params
    { email: user_unconfirmed.email }
  end

  def visit_email_confirmation_page(assert: false)
    get new_email_confirmation_path

    if assert
      assert_select 'form[action="/confirm-email"]' do
        assert_select 'input[name="email"]'
        assert_select 'button[type="submit"]'
      end
    end
  end
end
