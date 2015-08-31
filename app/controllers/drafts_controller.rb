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
    if @draft.raw_content == draft_content
      redirect_to edit_website_branch_draft_path(@website, @branch, @draft), alert: 'No changes detected.'
    elsif new_draft_id = BlobWriterService.perform(current_user, @website, @branch, @draft, draft_content, params[:message])
      redirect_to edit_website_branch_draft_path(@website, @branch, new_draft_id), notice: 'Great, we’ve committed your changes.'
    else
      flash.now.alert = 'There was a problem saving your changes.'
      render :edit, status: 422
    end
  end

  private

  def draft_content
    [YAML.dump((params[:draft].try(:[], :metadata) || {}).to_hash), params[:draft].try(:[], :content) || ''].join("---\n\n")
  end
end
