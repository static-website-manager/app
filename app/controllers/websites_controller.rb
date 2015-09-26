class WebsitesController < ApplicationController
  before_action :require_user
  before_action :require_website, only: %i[show]
  before_action :set_return_to, only: %i[index]

  def index
    @websites = current_user.websites
  end

  def show
    if @website.setup?
      redirect_to [@website, @website.branch(current_user)]
    else
      redirect_to [:new, @website, :setup]
    end
  end
end
