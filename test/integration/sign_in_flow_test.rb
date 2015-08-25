require 'test_helper'

class SignInFlowTest < ActionDispatch::IntegrationTest
  def test_sign_in
    visit_sign_in_page(assert: true)
  end

  def test_failed_sign_in
    visit_sign_in_page
    post_via_redirect new_session_path, invalid_params
    assert_response 422
    assert_equal new_session_path, path
  end

  def test_unconfirmed_sign_in
    visit_sign_in_page
    post_via_redirect new_session_path, unconfirmed_params
    assert_response 422
    assert_equal new_session_path, path
  end

  def test_successful_sign_in
    visit_sign_in_page
    post_via_redirect new_session_path, valid_params
    assert_response 200
    assert_equal websites_path, path
  end

  private

  def invalid_params
    { email: 'invalid@unknown.com', password: 'invalid', }
  end

  def unconfirmed_params
    { email: 'unconfirmed@unconfirmed.com', password: 'password', }
  end

  def valid_params
    { email: user.email, password: 'password', }
  end

  def visit_sign_in_page(assert: false)
    get new_session_path

    if assert
      assert_select 'form[action="/sign-in"]' do
        assert_select 'input[name="email"]'
        assert_select 'input[name="password"]'
        assert_select 'button[type="submit"]'
      end
    end
  end
end
