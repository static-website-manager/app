class SetupsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :set_return_to, only: %i[new]

  def new
    if @repository.setup?
      redirect_to [@website, @repository.branch(current_user)]
    end
  end

  def check
    if @repository.setup?
      render text: url_for([@website, @repository.branch(current_user)])
    else
      render text: ''
    end
  end
end
