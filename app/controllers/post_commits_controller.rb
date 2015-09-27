class PostCommitsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to

  before_action do
    @post = @branch.find_post(params[:post_id])
  end

  def index
    @commits = Commit.list(@repository.send(:rugged_repository), @branch.target, @post.full_pathname, per_page: 10)
  end
end
