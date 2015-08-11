class PagesController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern
  include CommitManagementConcern

  before_action only: %i[edit update] do
    @page = @tree.find_page(params[:id])
    @commits = Kaminari.paginate_array(@page.commits(@branch.raw_name)).page(1).per(10)
  end

  def index
    @pages = @tree.pages
  end

  def update
    if commit(@page)
      redirect_to [:edit, @website, @branch, @page], notice: 'Your changes were committed successfully.'
    else
      flash.now.alert = 'There was a problem committing your changes.'
      render :edit
    end
  end
end
