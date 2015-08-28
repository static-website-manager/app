class PostsController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  before_action only: %i[edit update] do
    @post = @branch.find_post(params[:id])
    @commits = @post.commits(@branch.target, per_page: 10)
  end

  def index
    @posts = @branch.posts(page: params[:page], per_page: 50)
  end

  def update
    if false
      redirect_to [:edit, @website, @branch, @post], notice: 'Your changes were committed successfully.'
    else
      flash.now.alert = 'There was a problem committing your changes.'
      render :edit
    end
  end
end
