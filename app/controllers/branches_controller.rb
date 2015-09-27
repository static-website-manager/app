class BranchesController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to

  def show
    @commits = Commit.list(@repository.send(:rugged_repository), @branch.commit_id, per_page: 10)
  end
end
