class DraftsController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  before_action only: %i[edit update] do
    @draft = @tree.find_draft(params[:id])
    @commits = Kaminari.paginate_array(@draft.commits(@branch.raw_name)).page(1).per(10)
  end
end
