require 'test_helper'

class SignOutFlowTest < ActionDispatch::IntegrationTest
  def test_sign_out
    sign_in users(:user_one)
    delete_via_redirect sign_out_path
    assert_response 200
    assert_equal root_path, path

    get_via_redirect websites_path
    assert_response 200
    assert_equal new_session_path, path
  end
end
