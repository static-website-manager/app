require 'test_helper'

class PagesFlowTest < ActionDispatch::IntegrationTest
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
    visit_edit_page('master', 'cb179d16d7b7dc4d1522a65cd9de876e3ccc9e90')
  end

  def test_working_edit
    visit_edit_page(user, 'cb179d16d7b7dc4d1522a65cd9de876e3ccc9e90')
  end

  def test_custom_edit
    visit_edit_page('custom', '081d05771a849ea8933e51a220821f68788dbe5f')
  end

  def test_master_update
    patch_update_page('master', 'cb179d16d7b7dc4d1522a65cd9de876e3ccc9e90')
  end

  def test_working_update
    patch_update_page(user, 'cb179d16d7b7dc4d1522a65cd9de876e3ccc9e90')
  end

  def test_custom_update
    patch_update_page('custom', '081d05771a849ea8933e51a220821f68788dbe5f')
  end

  private

  def visit_index_page(name_or_user)
    sign_in user
    get website_branch_pages_path(website, website.branch(name_or_user))
    assert_response 200
  end

  def visit_edit_page(name_or_user, page_sha1)
    sign_in user
    get edit_website_branch_page_path(website, website.branch(name_or_user), page_sha1)
    assert_response 200
    assert_select "form[action=\"#{website_branch_page_path}\"]" do
      assert_select 'button[type="submit"]'
    end
  end

  def patch_update_page(name_or_user, page_sha1)
    sign_in user
    patch_via_redirect website_branch_page_path(website, website.branch(name_or_user), page_sha1)
    assert_response 200
    assert_equal edit_website_branch_page_path(website, website.branch(name_or_user), page_sha1), path
  end
end
