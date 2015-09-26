class PageCommitsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to

  before_action do
    @page = @branch.find_page(params[:page_id])
  end

  def index
    @commits = @page.commits(@branch.target, page: params[:page])
  end
end
