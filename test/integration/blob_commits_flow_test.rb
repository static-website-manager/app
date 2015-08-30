require 'test_helper'

class BlobCommitsFlowTest < ActionDispatch::IntegrationTest
  def test_page_commits
    sign_in user
    get website_branch_blob_commits_path(website, 'master', 'cb179d16d7b7dc4d1522a65cd9de876e3ccc9e90')
    assert_response 200
  end

  def test_draft_commits
    sign_in user
    get website_branch_blob_commits_path(website, 'master', '5ca2eebcc4a00d1c95608c549fc39e287a462330')
    assert_response 200
  end

  def test_post_commits
    sign_in user
    get website_branch_blob_commits_path(website, 'master', 'a9327721a469cb5905ddfd767879ff0e6bc3d443')
    assert_response 200
  end
end
