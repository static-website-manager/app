require 'test_helper'

class WebsiteSettingsFlowTest < ActionDispatch::IntegrationTest
  def test_website_settings_as_new_website
    sign_in users(:user_one)
    get_via_redirect "/websites/#{websites(:new_website).id}/settings"
    assert_response 200
    assert_equal "/websites/#{websites(:new_website).id}/setup", path
    patch_via_redirect "/websites/#{websites(:new_website).id}/settings", valid_params
    assert_response 200
    assert_equal "/websites/#{websites(:new_website).id}/setup", path
    refute_equal 'Test', websites(:new_website).reload.name
  end

  def test_website_settings
    visit_settings_page(assert: true)
  end

  def test_failed_website_settings_update
    visit_settings_page
    patch_via_redirect "/websites/#{websites(:sample_website).id}/settings", invalid_params
    assert_response 422
    assert_equal "/websites/#{websites(:sample_website).id}/settings", path
    refute_equal '', websites(:sample_website).reload.name
  end

  def test_successfull_website_settings_update
    visit_settings_page
    patch_via_redirect "/websites/#{websites(:sample_website).id}/settings", valid_params
    assert_response 200
    assert_equal "/websites/#{websites(:sample_website).id}/working", path
    assert_equal 'Test', websites(:sample_website).reload.name
  end

  private

  def visit_settings_page(assert: false)
    sign_in users(:user_one)
    get_via_redirect "/websites/#{websites(:sample_website).id}/settings"

    if assert
      assert_response 200
      assert_equal "/websites/#{websites(:sample_website).id}/settings", path
    end
  end

  def invalid_params
    { website: { name: '' }}
  end

  def valid_params
    { website: { name: 'Test' }}
  end
end
