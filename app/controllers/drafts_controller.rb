class DraftsController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern
  include CommitManagementConcern

  before_action only: %i[edit update] do
    @draft = @tree.find_draft(params[:id])
    @commits = Kaminari.paginate_array(@draft.commits(@branch.raw_name)).page(1).per(10)
  end

  def index
    @drafts = @tree.drafts
  end

  def update
    if commit(@draft)
      redirect_to [:edit, @website, @branch, @draft], notice: 'Your changes were committed successfully.'
    else
      flash.now.alert = 'There was a problem committing your changes.'
      render :edit
    end
  end
end
