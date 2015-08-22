require 'test_helper'

class RootFlowTest < ActionDispatch::IntegrationTest
  def test_root
    get root_path
    assert_response 200
    assert_select 'a[href="/subscribe"]'
    assert_select 'a[href="/sign-in"]'
  end
end
