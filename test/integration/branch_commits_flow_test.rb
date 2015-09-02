require 'test_helper'

class BranchCommitsFlowTest < ActionDispatch::IntegrationTest
  def test_commits
    sign_in user
    get website_branch_commits_path(website, website.branch(user))
    assert_response 200
  end
end
