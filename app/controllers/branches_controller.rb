class BranchesController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  def show
    @commits = Kaminari.paginate_array(@branch.commits).page(params[:page]).per(20)
  end
end
