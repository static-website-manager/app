class SetupsController < ApplicationController
  before_action :require_user

  before_action do
    @website = current_user.websites.find(params[:website_id])

    if @website.repository.branch?(:master)
      redirect_to @website
    end
  end
end
