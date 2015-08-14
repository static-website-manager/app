class DraftsController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  before_action only: %i[edit update] do
    @draft = @branch.find_draft(params[:id])
    @commits = @draft.commits(@branch.raw_name, per_page: 10)
  end

  def index
    @drafts = @branch.drafts
  end

  def update
    if false
      redirect_to [:edit, @website, @branch, @draft], notice: 'Your changes were committed successfully.'
    else
      flash.now.alert = 'There was a problem committing your changes.'
      render :edit
    end
  end
end
