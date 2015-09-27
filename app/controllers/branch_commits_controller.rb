class BranchCommitsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to

  def index
    @commits = Commit.all(@repository.send(:rugged_repository), @branch.commit_id, page: params[:page])
  end
end
