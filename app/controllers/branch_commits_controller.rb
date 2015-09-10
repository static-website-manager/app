class BranchCommitsController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  def index
    @commits = @branch.commits(page: params[:page])
    session[:return_to] = request.path
  end
end
