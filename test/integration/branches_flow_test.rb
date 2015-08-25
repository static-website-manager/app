require 'test_helper'

class BranchesFlowTest < ActionDispatch::IntegrationTest
  def test_master_branch
    sign_in user
    get website_branch_path(website, 'master')
    assert_response 200
  end

  def test_working_branch
    sign_in user
    get website_branch_path(website, website.branch(user))
    assert_response 200
  end

  def test_custom_branch
    sign_in user
    get website_branch_path(website, 'custom')
    assert_response 200
  end

  def test_unknown_branch
    sign_in user
    assert_raises 'ActiveRecord::RecordNotFound' do
      get website_branch_path(website, 'unkown')
    end
  end
end
