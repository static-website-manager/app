class BranchesController < ApplicationController
  include WebsiteConcern
  include BranchConcern

  before_action :set_return_to

  def show
    @commits = @branch.commits(per_page: 10)
  end
end
