require 'test_helper'

class ComparisonsFlowTest < ActionDispatch::IntegrationTest
  def test_master_master_branch
    sign_in user
    assert_raises 'ActiveRecord::RecordNotFound' do
      get website_branch_branch_path(website, 'master', 'master')
    end
  end

  def test_master_working_branch
    sign_in user
    get website_branch_branch_path(website, 'master', 'working')
    assert_response 200
  end

  def test_master_custom_branch
    sign_in user
    get website_branch_branch_path(website, 'master', 'working')
    assert_response 200
  end

  def test_working_master_branch
    sign_in user
    get website_branch_branch_path(website, 'working', 'master')
    assert_response 200
  end

  def test_working_working_branch
    sign_in user
    assert_raises 'ActiveRecord::RecordNotFound' do
      get website_branch_branch_path(website, 'working', 'working')
    end
  end

  def test_working_custom_branch
    sign_in user
    get website_branch_branch_path(website, 'working', 'custom')
    assert_response 200
  end

  def test_custom_master_branch
    sign_in user
    get website_branch_branch_path(website, 'custom', 'master')
    assert_response 200
  end

  def test_custom_working_branch
    sign_in user
    get website_branch_branch_path(website, 'custom', 'working')
    assert_response 200
  end

  def test_custom_custom_branch
    sign_in user
    assert_raises 'ActiveRecord::RecordNotFound' do
      get website_branch_branch_path(website, 'custom', 'custom')
    end
  end
end
