class BranchesController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  def show
    @commits = @branch.commits(per_page: 10)
    session[:return_to] = request.path
  end
end
