require 'test_helper'

class SignInFlowTest < ActionDispatch::IntegrationTest
  def test_sign_in
    visit_sign_in_page(assert: true)
  end

  def test_failed_sign_in
    visit_sign_in_page
    post_via_redirect '/sign-in', invalid_params
    assert_response 422
    assert_equal '/sign-in', path
  end

  def test_unconfirmed_sign_in
    visit_sign_in_page
    post_via_redirect '/sign-in', unconfirmed_params
    assert_response 422
    assert_equal '/sign-in', path
  end

  def test_successful_sign_in
    visit_sign_in_page
    post_via_redirect '/sign-in', valid_params
    assert_response 200
    assert_equal '/websites', path
  end

  private

  def invalid_params
    { email: 'invalid@unknown.com', password: 'invalid', }
  end

  def unconfirmed_params
    { email: 'unconfirmed@unconfirmed.com', password: 'password', }
  end

  def valid_params
    { email: users(:user_one).email, password: 'password', }
  end

  def visit_sign_in_page(assert: false)
    get '/sign-in'

    if assert
      assert_select 'form[action="/sign-in"]' do
        assert_select 'input[name="email"]'
        assert_select 'input[name="password"]'
        assert_select 'button[type="submit"]'
      end
    end
  end
end
