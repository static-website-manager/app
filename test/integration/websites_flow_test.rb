require 'test_helper'

class WebsitesFlowTest < ActionDispatch::IntegrationTest
  def test_websites
    sign_in user
    get websites_path
    assert_response 200
  end

  def test_new_website
    sign_in user
    get_via_redirect website_path(website_new)
    assert_response 200
    assert_equal new_website_setup_path(website_new), path
  end

  def test_setup_website
    sign_in user
    get_via_redirect website_path(website)
    assert_response 200
    assert_equal website_branch_path(website, 'working'), path
  end
end
