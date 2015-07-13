class DraftsController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  before_action only: %i[edit update] do
    @draft = @tree.find_draft(params[:id])
  end
end
