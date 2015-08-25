require 'test_helper'

class SetupsFlowTest < ActionDispatch::IntegrationTest
  def test_setup
    visit_setup_page(website_new)
  end

  def test_setup_and_wait_for_repository
    # visit_setup_page(website_new, assert: false)
    # wait and push to master and follow redirect
    # assert_response 200
    # assert_equal website_branch_path(website_new, website_new.branch(user)), path
  end

  def test_setup_as_sample_website
    visit_setup_page(website, assert: false)
    assert_response 200
    assert_equal website_branch_path(website, website.branch(user)), path
  end

  private

  def visit_setup_page(website, assert: false)
    sign_in user
    get_via_redirect new_website_setup_path(website)

    if assert
      assert_response 200
      assert_equal new_website_setup_path(website), path
    end
  end
end
