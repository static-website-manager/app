class PostsController < ApplicationController
  before_action :require_user

  before_action do
    @website = current_user.websites.find(params[:website_id])
    @branch = @website.repository.branches.find(params[:branch_id])
  end
end
