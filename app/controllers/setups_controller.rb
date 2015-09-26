class SetupsController < ApplicationController
  before_action :require_user
  before_action :require_website

  before_action do
    @repository = Repository.new(website_id: website_id)
  end

  def new
    if @repository.setup?
      redirect_to [@website, @website.branch(current_user)]
    end
  end

  def check
    if @repository.setup?
      render text: url_for([@website, @website.branch(current_user)])
    else
      render text: ''
    end
  end
end
