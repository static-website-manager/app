class DraftsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to, only: %i[index show]

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
  end

  def update
    new_id = @draft.save(@website, @branch, current_user, draft_content, params[:message])

    if new_id.present? && new_id == @draft.id
      redirect_to website_branch_draft_path(@website, @branch, @draft), alert: 'No changes detected.'
    elsif new_id
      redirect_to website_branch_draft_path(@website, @branch, new_id), notice: 'Great, we’ve committed your changes.'
    else
      flash.now.alert = 'There was a problem saving your changes.'
      render :edit, status: 422
    end
  end

  private

  def draft_content
    if params[:draft].try(:[], :metadata).present?
      [YAML.dump(params[:draft][:metadata].to_hash), @draft.writable? ? params[:draft].try(:[], :content) || '' : @draft.content].join("---\n\n")
    else
      @draft.writable? ? params[:draft].try(:[], :content) || '' : @draft.content
    end
  end
end
