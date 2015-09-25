class BranchesController < ApplicationController
  include WebsiteConcern
  include BranchConcern

  def show
    @commits = @branch.commits(per_page: 10)
  end
end
