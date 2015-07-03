class SetupChecksController < ApplicationController
  before_action :require_user

  before_action do
    @website = current_user.websites.find(params[:website_id])
    @repository = @website.repository
  end

  def show
    if @repository.setup?
      render text: url_for([@website, @repository.branch(current_user)])
    else
      render text: ''
    end
  end
end
