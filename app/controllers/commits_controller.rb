class CommitsController < ApplicationController
  include WebsiteConcern

  def show
    @commit = @website.commit(params[:id])
  end
end
