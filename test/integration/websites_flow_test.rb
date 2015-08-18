require 'test_helper'

class WebsitesFlowTest < ActionDispatch::IntegrationTest
  def test_websites
    sign_in users(:user_one)
    get '/websites'
    assert_response 200
  end

  def test_new_website
    sign_in users(:user_one)
    get_via_redirect "/websites/#{websites(:new_website).id}"
    assert_response 200
    assert_equal "/websites/#{websites(:new_website).id}/setup", path
  end

  def test_setup_website
    sign_in users(:user_one)
    get_via_redirect "/websites/#{websites(:sample_website).id}"
    assert_response 200
    assert_equal "/websites/#{websites(:sample_website).id}/working", path
  end
end
