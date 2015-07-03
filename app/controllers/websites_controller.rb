class WebsitesController < ApplicationController
  before_action :require_user

  def index
    @websites = current_user.websites
  end

  def show
    @website = current_user.websites.find(params[:id])
    @repository = @website.repository

    if @repository.setup?
      redirect_to [@website, @repository.branch(current_user)]
    else
      redirect_to [:new, @website, :setup]
    end
  end
end
