class PostsController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  before_action only: %i[edit update] do
    @post = @tree.find_post(params[:id])
    @commits = Kaminari.paginate_array(@post.commits(@branch.raw_name)).page(1).per(10)
  end

  def index
    @posts = Kaminari.paginate_array(@tree.posts).page(params[:page]).per(50)
  end
end
