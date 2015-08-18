require 'test_helper'

class SignOutFlowTest < ActionDispatch::IntegrationTest
  def test_sign_out
    sign_in users(:user_one)
    delete_via_redirect '/sign-out'
    assert_response 200
    assert_equal '/', path

    get_via_redirect '/websites'
    assert_response 200
    assert_equal '/sign-in', path
  end
end
