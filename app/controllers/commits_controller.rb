class CommitsController < ApplicationController
  include WebsiteConcern

  def show
    @commit = @website.commit(params[:id])
    session[:return_to] = request.path
  end
end
