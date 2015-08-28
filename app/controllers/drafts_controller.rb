class DraftsController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  before_action only: %i[edit update] do
    @draft = @branch.find_draft(params[:id])
    @commits = @draft.commits(@branch.target, per_page: 10)
  end

  def index
    @drafts = @branch.drafts
  end

  def update
    redirect_to [:edit, @website, @branch, @draft]
  end
end
