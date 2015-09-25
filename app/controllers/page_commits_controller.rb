class PageCommitsController < ApplicationController
  include WebsiteConcern
  include BranchConcern

  before_action do
    @page = @branch.find_page(params[:page_id])
  end

  def index
    @commits = @page.commits(@branch.target, page: params[:page])
  end
end
