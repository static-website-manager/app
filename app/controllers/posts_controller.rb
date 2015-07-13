class PostsController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  before_action only: %i[edit update] do
    @post = @tree.find_post(params[:id])
  end
end
