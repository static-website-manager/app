require 'test_helper'

class PasswordsFlowTest < ActionDispatch::IntegrationTest
  def test_edit_password
    visit_edit_password_page
  end

  def test_failed_edit_password
    patch_via_redirect password_path(token: user.password_reset_token), invalid_params
    assert_response 422
    assert_equal edit_password_path, path
  end

  def test_successful_edit_password
    patch_via_redirect password_path(token: user.password_reset_token), valid_params
    assert_response 200
    assert_equal websites_path, path
  end

  def test_successful_edit_password_unconfirmed_user
    patch_via_redirect password_path(token: user_unconfirmed.password_reset_token), valid_params
    assert_response 200
    assert_equal websites_path, path
  end

  private

  def invalid_params
    {
      user: {
        password: 'password',
        password_confirmation: 'pass',
      },
    }
  end

  def valid_params
    {
      user: {
        password: 'password',
        password_confirmation: 'password',
      },
    }
  end

  def visit_edit_password_page(assert: false)
    get edit_password_path(token: user.password_reset_token)

    assert_select 'form[action="/password?token=' + user.password_reset_token + '"]' do
      assert_select 'input[name="user[password]"]'
      assert_select 'input[name="user[password_confirmation]"]'
      assert_select 'button[type="submit"]'
    end
  end
end
