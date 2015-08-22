require 'test_helper'

class WebsiteSettingsFlowTest < ActionDispatch::IntegrationTest
  def test_website_settings_as_new_website
    sign_in users(:user_one)
    get_via_redirect edit_website_settings_path(websites(:new_website))
    assert_response 200
    assert_equal new_website_setup_path(websites(:new_website)), path
    patch_via_redirect edit_website_settings_path(websites(:new_website)), valid_params
    assert_response 200
    assert_equal new_website_setup_path(websites(:new_website)), path
    refute_equal 'Test', websites(:new_website).reload.name
  end

  def test_website_settings
    visit_settings_page(assert: true)
  end

  def test_failed_website_settings_update
    visit_settings_page
    patch_via_redirect edit_website_settings_path(websites(:sample_website)), invalid_params
    assert_response 422
    assert_equal edit_website_settings_path(websites(:sample_website)), path
    refute_equal '', websites(:sample_website).reload.name
  end

  def test_successfull_website_settings_update
    visit_settings_page
    patch_via_redirect edit_website_settings_path(websites(:sample_website)), valid_params
    assert_response 200
    assert_equal website_branch_path(websites(:sample_website), websites(:sample_website).branch(users(:user_one))), path
    assert_equal 'Test', websites(:sample_website).reload.name
  end

  private

  def visit_settings_page(assert: false)
    sign_in users(:user_one)
    get_via_redirect edit_website_settings_path(websites(:sample_website))

    if assert
      assert_response 200
      assert_equal edit_website_settings_path(websites(:sample_website)), path
    end
  end

  def invalid_params
    { website: { name: '' }}
  end

  def valid_params
    { website: { name: 'Test' }}
  end
end
