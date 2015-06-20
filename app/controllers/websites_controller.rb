class WebsitesController < ApplicationController
  def index
    @websites = Website.all
  end

  def show
    @website = Website.find(params[:id])

    if !@website.setup?
      redirect_to [@website, :setup]
    end
  end
end
