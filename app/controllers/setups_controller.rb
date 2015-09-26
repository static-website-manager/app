class SetupsController < ApplicationController
  before_action :require_user
  before_action :require_website

  def new
    if @website.setup?
      redirect_to [@website, @website.branch(current_user)]
    end
  end

  def check
    if @website.setup?
      render text: url_for([@website, @website.branch(current_user)])
    else
      render text: ''
    end
  end
end
