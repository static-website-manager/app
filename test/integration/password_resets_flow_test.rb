require 'test_helper'

class PasswordResetFlowTest < ActionDispatch::IntegrationTest
  def test_password_reset
    visit_password_reset_page(assert: true)
  end

  def test_failed_password_reset
    visit_password_reset_page
    post_via_redirect new_password_reset_path, invalid_params
    assert_response 422
    assert_equal new_password_reset_path, path
  end

  def test_successful_password_reset
    visit_password_reset_page
    post_via_redirect new_password_reset_path, valid_params
    assert_response 200
    assert_equal root_path, path
  end

  private

  def invalid_params
    { email: 'invalid@unknown.com' }
  end

  def valid_params
    { email: user.email }
  end

  def visit_password_reset_page(assert: false)
    get new_password_reset_path

    if assert
      assert_select 'form[action="/reset-password"]' do
        assert_select 'input[name="email"]'
        assert_select 'button[type="submit"]'
      end
    end
  end
end
