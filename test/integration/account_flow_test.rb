require 'test_helper'

class AccountFlowTest < ActionDispatch::IntegrationTest
  def test_account
    visit_account_page(assert: true)
  end

  def test_failed_account_update
    visit_account_page
    patch_via_redirect edit_account_path, invalid_params
    assert_response 422
    assert_equal edit_account_path, path
    refute_equal '', user.reload.name
  end

  def test_successfull_account_update
    visit_account_page
    patch_via_redirect edit_account_path, valid_params
    assert_response 200
    assert_equal websites_path, path
    assert_equal 'Test', user.reload.name
  end

  private

  def visit_account_page(assert: false)
    sign_in user
    get_via_redirect edit_account_path

    if assert
      assert_response 200
      assert_equal edit_account_path, path
    end
  end

  def invalid_params
    { user: { name: '' }}
  end

  def valid_params
    { user: { name: 'Test' }}
  end
end
