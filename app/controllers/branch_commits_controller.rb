class BranchCommitsController < ApplicationController
  include WebsiteConcern
  include BranchConcern

  def index
    @commits = @branch.commits(page: params[:page])
    session[:return_to] = request.path
  end
end
