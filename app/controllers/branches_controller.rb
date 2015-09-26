class BranchesController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_setup_repository
  before_action :require_branch
  before_action :set_return_to

  def show
    @commits = @branch.commits(per_page: 10)
  end
end
