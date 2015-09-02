require 'test_helper'

class CommitsFlowTest < ActionDispatch::IntegrationTest
  def test_commit
    sign_in user
    get website_commit_path(website, '0933fd78299541bbe60436c0140a1a3557864539')
    assert_response 200
  end
end
