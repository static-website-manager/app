class PagesController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  before_action only: %i[edit update] do
    @page = @branch.find_page(params[:id])
    @commits = @page.commits(@branch.raw_name, per_page: 10)
  end

  def index
    @pages = @branch.pages
  end

  def update
    if false
      redirect_to [:edit, @website, @branch, @page], notice: 'Your changes were committed successfully.'
    else
      flash.now.alert = 'There was a problem committing your changes.'
      render :edit
    end
  end
end
