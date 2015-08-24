require 'test_helper'

class WebsiteSetupsFlowTest < ActionDispatch::IntegrationTest
  def test_website_setup
    visit_website_setup_page(websites(:new_website))
  end

  def test_website_setup_and_wait_for_repository
    # visit_website_setup_page(websites(:new_website), assert: false)
    # wait and push to master and follow redirect
    # assert_response 200
    # assert_equal website_branch_path(websites(:new_website), websites(:new_website).branch(users(:user_one))), path
  end

  def test_website_setup_as_sample_website
    visit_website_setup_page(websites(:sample_website), assert: false)
    assert_response 200
    assert_equal website_branch_path(websites(:sample_website), websites(:sample_website).branch(users(:user_one))), path
  end

  private

  def visit_website_setup_page(website, assert: false)
    sign_in users(:user_one)
    get_via_redirect new_website_setup_path(website)

    if assert
      assert_response 200
      assert_equal new_website_setup_path(website), path
    end
  end
end
