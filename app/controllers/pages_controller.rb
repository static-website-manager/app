class PagesController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  before_action only: %i[edit update] do
    @page = @tree.find_page(params[:id])
    @commits = Kaminari.paginate_array(@page.commits(@branch.raw_name)).page(1).per(10)
  end
end
