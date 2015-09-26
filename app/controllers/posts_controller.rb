class PostsController < ApplicationController
  include WebsiteConcern
  include BranchConcern

  before_action only: %i[show edit update] do
    @post = @branch.find_post(params[:id])
  end

  def index
    @posts = @branch.posts(page: params[:page], per_page: 50)
  end

  def new
  end

  def create
  end

  def show
    @commits = @post.commits(@branch.target, per_page: 10)
  end

  def edit
  end

  def update
    new_id = @post.save(@website, @branch, current_user, post_content, params[:message])

    if new_id.present? && new_id == @post.id
      redirect_to website_branch_post_path(@website, @branch, @post), alert: 'No changes detected.'
    elsif new_id.present?
      redirect_to website_branch_post_path(@website, @branch, new_id), notice: 'Great, we’ve committed your changes.'
    else
      flash.now.alert = 'There was a problem saving your changes.'
      render :edit, status: 422
    end
  end

  private

  def post_content
    if params[:post].try(:[], :metadata).present?
      [YAML.dump(params[:post][:metadata].to_hash), @post.writable? ? params[:post].try(:[], :content) || '' : @post.content].join("---\n\n")
    else
      @post.writable? ? params[:post].try(:[], :content) || '' : @post.content
    end
  end
end
