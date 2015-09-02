require 'test_helper'

class BlobCommitsFlowTest < ActionDispatch::IntegrationTest
  def test_commits
    sign_in user
    get website_branch_blob_commits_path(website, website.branch(user), '5ca2eebcc4a00d1c95608c549fc39e287a462330')
    assert_response 200
  end
end
