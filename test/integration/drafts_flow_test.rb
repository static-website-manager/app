require 'test_helper'

class DraftsFlowTest < ActionDispatch::IntegrationTest
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
    visit_edit_page('master', '5ca2eebcc4a00d1c95608c549fc39e287a462330')
  end

  def test_working_edit
    visit_edit_page(user, '5ca2eebcc4a00d1c95608c549fc39e287a462330')
  end

  def test_custom_edit
    visit_edit_page('custom', 'a9441d8aaaacb7a9f580b90a9edc6598c99bc877')
  end

  def test_successful_master_update
    patch_update_page('master', '5ca2eebcc4a00d1c95608c549fc39e287a462330', valid_params)
  end

  def test_successful_working_update
    patch_update_page(user, '5ca2eebcc4a00d1c95608c549fc39e287a462330', valid_params)
  end

  def test_successful_custom_update
    patch_update_page('custom', 'a9441d8aaaacb7a9f580b90a9edc6598c99bc877', valid_params)
  end

  private

  def visit_index_page(name_or_user)
    sign_in user
    get website_branch_drafts_path(website, website.branch(name_or_user))
    assert_response 200
  end

  def visit_edit_page(name_or_user, draft_sha1)
    sign_in user
    get edit_website_branch_draft_path(website, website.branch(name_or_user), draft_sha1)
    assert_response 200
    assert_select "form[action=\"#{website_branch_draft_path}\"]" do
      assert_select 'button[type="submit"]'
    end
  end

  def patch_update_page(name_or_user, draft_sha1, draft_params)
    sign_in user
    patch_via_redirect website_branch_draft_path(website, website.branch(name_or_user), draft_sha1, draft_params)
    assert_response 200
    assert_equal edit_website_branch_draft_path(website, website.branch(name_or_user), draft_sha1, draft_params), path
  end

  def valid_params
    { draft_params: {
        metadata: {
          title: 'Test',
        },
        content: 'Test Content',
      },
    }
  end
end