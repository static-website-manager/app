class CommitsController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  def index
    @commits = @branch.commits(page: params[:page])
  end
end
