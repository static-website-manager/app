class PagesController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  before_action only: %i[edit update] do
    @page = @branch.find_page(params[:id])
    @commits = @page.commits(@branch.target, per_page: 10)
  end

  def index
    @pages = @branch.pages
  end

  def update
    redirect_to [:edit, @website, @branch, @page]
  end
end
