class PagesController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  before_action only: %i[edit update] do
    @page = @tree.find_page(params[:id])
  end
end
