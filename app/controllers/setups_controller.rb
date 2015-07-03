class SetupsController < ApplicationController
  before_action :require_user

  before_action do
    @website = current_user.websites.find(params[:website_id])
    @repository = @website.repository

    if @website.setup?
      redirect_to [@website, @website.branch(current_user)]
    end
  end
end
