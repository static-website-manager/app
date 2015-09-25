class DraftsController < ApplicationController
  include WebsiteConcern
  include BranchConcern

  before_action only: %i[edit update] do
    @draft = @branch.find_draft(params[:id])
    @commits = @draft.commits(@branch.target, per_page: 10)
    @blob_commit = BlobCommit.new(current_user, @website, @branch, @draft)
  end

  def index
    @drafts = @branch.drafts
  end

  def update
    @blob_commit.save(draft_content, params[:message])

    if @blob_commit.id.present? && @blob_commit.id == @draft.id
      redirect_to edit_website_branch_draft_path(@website, @branch, @draft), alert: 'No changes detected.'
    elsif @blob_commit.id.present?
      redirect_to edit_website_branch_draft_path(@website, @branch, @blob_commit.id), notice: 'Great, we’ve committed your changes.'
    else
      flash.now.alert = 'There was a problem saving your changes.'
      render :edit, status: 422
    end
  end

  private

  def draft_content
    if params[:draft].try(:metadata).present?
      [YAML.dump(params[:draft][:metadata].to_hash), @draft.writable? ? params[:draft].try(:[], :content) || '' : @draft.content].join("---\n\n")
    else
      @draft.writable? ? params[:draft].try(:[], :content) || '' : @draft.content
    end
  end
end
