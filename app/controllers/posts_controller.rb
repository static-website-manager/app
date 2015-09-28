class PostsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to, only: %i[index show]

  before_action only: %i[new create] do
    @post = Post.new(rugged_repository: @repository.send(:rugged_repository), pathname: '_posts')
  end

  before_action only: %i[show edit update] do
    @post = Post.find(@repository.send(:rugged_repository), @branch.commit_id, params[:id])
  end

  def index
    @posts = Post.all(@repository.send(:rugged_repository), @branch.commit_id, page: params[:page], per_page: 50)
  end

  def create
    if success
      redirect_to website_branch_post_path(@website, @branch, @post), notice: 'Great, we’ve committed your changes.'
    else
      flash.now.alert = 'There was a problem saving your changes.'
      render :edit, status: 422
    end
  end

  def show
    @commits = Commit.all(@repository.send(:rugged_repository), @branch.commit_id, pathname: @post.full_pathname, per_page: 10)
  end

  def update
    if save
      redirect_to website_branch_post_path(@website, @branch, @post), alert: 'No changes detected.'
    elsif success
      redirect_to website_branch_post_path(@website, @branch, @post), notice: 'Great, we’ve committed your changes.'
    else
      flash.now.alert = 'There was a problem saving your changes.'
      render :edit, status: 422
    end
  end
end
