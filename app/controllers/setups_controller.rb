class SetupsController < ApplicationController
  include WebsiteConcern

  def new
    if @website.setup?
      redirect_to [@website, @website.branch(current_user)]
    end
  end

  def show
    if @website.setup?
      render text: url_for([@website, @website.branch(current_user)])
    else
      render text: ''
    end
  end
end
