class BranchesController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  def show
    @commits = @branch.commits
  end
end
