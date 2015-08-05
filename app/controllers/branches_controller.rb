class BranchesController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  def show
    @commits = Kaminari.paginate_array(@branch.commits).page(1).per(10)
  end
end
