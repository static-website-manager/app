class PostCommitsController < ApplicationController
  include WebsiteConcern
  include BranchConcern

  before_action do
    @post = @branch.find_post(params[:post_id])
  end

  def index
    @commits = @post.commits(@branch.target, page: params[:page])
  end
end
