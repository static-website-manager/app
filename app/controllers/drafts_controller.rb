class DraftsController < ApplicationController
  include WebsiteConcern
  include BranchConcern

  before_action only: %i[show edit update] do
    @draft = @branch.find_draft(params[:id])
  end

  def index
    @drafts = @branch.drafts
  end

  def new
  end

  def create
  end

  def show
    @commits = @draft.commits(@branch.target, per_page: 10)
  end

  def edit
    @blob_commit = BlobCommit.new(current_user, @website, @branch, @draft)
  end

  def update
    @blob_commit = BlobCommit.new(current_user, @website, @branch, @draft)
    @blob_commit.save(draft_content, params[:message])

    if @blob_commit.id.present? && @blob_commit.id == @draft.id
      redirect_to website_branch_draft_path(@website, @branch, @draft), alert: 'No changes detected.'
    elsif @blob_commit.id.present?
      redirect_to website_branch_draft_path(@website, @branch, @blob_commit.id), notice: 'Great, we’ve committed your changes.'
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
