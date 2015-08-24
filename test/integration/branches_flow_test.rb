require 'test_helper'

class BranchesFlowTest < ActionDispatch::IntegrationTest
  def test_master_branch
    sign_in users(:user_one)
    get website_branch_path(websites(:sample_website), 'master')
    assert_response 200
  end

  def test_working_branch
    sign_in users(:user_one)
    get website_branch_path(websites(:sample_website), websites(:sample_website).branch(users(:user_one)))
    assert_response 200
  end

  def test_custom_branch
    sign_in users(:user_one)
    get website_branch_path(websites(:sample_website), 'custom')
    assert_response 200
  end

  def test_unknown_branch
    sign_in users(:user_one)
    assert_raises 'ActiveRecord::RecordNotFound' do
      get website_branch_path(websites(:sample_website), 'unkown')
    end
  end
end
