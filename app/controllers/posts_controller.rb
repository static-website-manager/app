class PostsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to, only: %i[index show]

  before_action only: %i[show edit update] do
    @post = Post.find(@repository.send(:rugged_repository), @branch.tree, params[:id])
  end

  def index
    @posts = @branch.posts(page: params[:page], per_page: 50)
  end

  def new
  end

  def create
  end

  def show
    @commits = Commit.list(@repository.send(:rugged_repository), @branch.target, pathname: @post.full_pathname, per_page: 10)
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
