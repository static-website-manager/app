class PostsController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  before_action only: %i[edit update] do
    @post = @branch.find_post(params[:id])
    @commits = @post.commits(@branch.target, per_page: 10)
    @blob_commit = BlobCommit.new(current_user, @website, @branch, @post)
  end

  def index
    @posts = @branch.posts(page: params[:page], per_page: 50)
  end

  def update
    @blob_commit.save(post_content, params[:message])

    if @blob_commit.id.present? && @blob_commit.id == @post.id
      redirect_to edit_website_branch_post_path(@website, @branch, @post), alert: 'No changes detected.'
    elsif @blob_commit.id.present?
      redirect_to edit_website_branch_post_path(@website, @branch, @blob_commit.id), notice: 'Great, we’ve committed your changes.'
    else
      flash.now.alert = 'There was a problem saving your changes.'
      render :edit, status: 422
    end
  end

  private

  def post_content
    [YAML.dump((params[:post].try(:[], :metadata) || {}).to_hash), params[:post].try(:[], :content) || ''].join("---\n\n")
  end
end
