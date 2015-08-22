require 'test_helper'

class WebsitesFlowTest < ActionDispatch::IntegrationTest
  def test_websites
    sign_in users(:user_one)
    get websites_path
    assert_response 200
  end

  def test_new_website
    sign_in users(:user_one)
    get_via_redirect website_path(websites(:new_website))
    assert_response 200
    assert_equal new_website_setup_path(websites(:new_website)), path
  end

  def test_setup_website
    sign_in users(:user_one)
    get_via_redirect website_path(websites(:sample_website))
    assert_response 200
    assert_equal website_branch_path(websites(:sample_website), 'working'), path
  end
end
