class PageCommitsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to

  before_action do
    @page = Page.find(@repository.send(:rugged_repository), @branch.tree, params[:page_id])
  end

  def index
    @commits = Commit.list(@repository.send(:rugged_repository), @branch.target, pathname: @page.full_pathname, page: params[:page])
  end
end
