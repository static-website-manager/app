class WebsitesController < ApplicationController
  before_action :require_user

  def index
    @websites = current_user.websites
  end

  def show
    @website = current_user.websites.find(params[:id])

    redirect_to [@website, @website.branch(current_user)]
  end
end
