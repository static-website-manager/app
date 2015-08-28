require 'test_helper'

class PostsFlowTest < ActionDispatch::IntegrationTest
  def test_master_index
    visit_index_page('master')
  end

  def test_working_index
    visit_index_page(user)
  end

  def test_custom_index
    visit_index_page('custom')
  end

  def test_master_edit
    visit_edit_page('master', 'a9327721a469cb5905ddfd767879ff0e6bc3d443')
  end

  def test_working_edit
    visit_edit_page(user, 'a9327721a469cb5905ddfd767879ff0e6bc3d443')
  end

  def test_custom_edit
    visit_edit_page('custom', 'f320e03c26b594dc3f97c9ce6bdb2b13861ed5a3')
  end

  def test_master_update
    patch_update_page('master', 'a9327721a469cb5905ddfd767879ff0e6bc3d443')
  end

  def test_working_update
    patch_update_page(user, 'a9327721a469cb5905ddfd767879ff0e6bc3d443')
  end

  def test_custom_update
    patch_update_page('custom', 'f320e03c26b594dc3f97c9ce6bdb2b13861ed5a3')
  end

  private

  def visit_index_page(name_or_user)
    sign_in user
    get website_branch_posts_path(website, website.branch(name_or_user))
    assert_response 200
  end

  def visit_edit_page(name_or_user, post_sha1)
    sign_in user
    get edit_website_branch_post_path(website, website.branch(name_or_user), post_sha1)
    assert_response 200
    assert_select "form[action=\"#{website_branch_post_path}\"]" do
      assert_select 'button[type="submit"]'
    end
  end

  def patch_update_page(name_or_user, post_sha1)
    sign_in user
    patch_via_redirect website_branch_post_path(website, website.branch(name_or_user), post_sha1)
    assert_response 200
    assert_equal edit_website_branch_post_path(website, website.branch(name_or_user), post_sha1), path
  end
end
