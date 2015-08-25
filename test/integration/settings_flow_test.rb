require 'test_helper'

class SettingsFlowTest < ActionDispatch::IntegrationTest
  def test_settings_as_new_website
    sign_in user
    get_via_redirect edit_website_settings_path(website_new)
    assert_response 200
    assert_equal new_website_setup_path(website_new), path
    patch_via_redirect edit_website_settings_path(website_new), valid_params
    assert_response 200
    assert_equal new_website_setup_path(website_new), path
    refute_equal 'Test', website_new.reload.name
  end

  def test_settings
    visit_settings_page(assert: true)
  end

  def test_failed_settings_update
    visit_settings_page
    patch_via_redirect edit_website_settings_path(website), invalid_params
    assert_response 422
    assert_equal edit_website_settings_path(website), path
    refute_equal '', website.reload.name
  end

  def test_successfull_settings_update
    visit_settings_page
    patch_via_redirect edit_website_settings_path(website), valid_params
    assert_response 200
    assert_equal website_branch_path(website, website.branch(user)), path
    assert_equal 'Test', website.reload.name
  end

  private

  def visit_settings_page(assert: false)
    sign_in user
    get_via_redirect edit_website_settings_path(website)

    if assert
      assert_response 200
      assert_equal edit_website_settings_path(website), path
    end
  end

  def invalid_params
    { website: { name: '' }}
  end

  def valid_params
    { website: { name: 'Test' }}
  end
end
