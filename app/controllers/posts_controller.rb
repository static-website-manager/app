class PostsController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  def index
    @posts = @tree.posts
  end
end
