class PagesController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  def index
    @pages = @tree.pages
  end
end
