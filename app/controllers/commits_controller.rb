class CommitsController < ApplicationController
  include WebsiteManagementConcern

  def show
    @commit = @website.commit(params[:id])
  end
end
