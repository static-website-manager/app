class BranchCommitsController < ApplicationController
  include WebsiteConcern
  include BranchConcern

  before_action :set_return_to

  def index
    @commits = @branch.commits(page: params[:page])
  end
end
