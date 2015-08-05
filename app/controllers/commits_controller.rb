class CommitsController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  def index
    @commits = Kaminari.paginate_array(@branch.commits).page(params[:page]).per(20)
  end
end
