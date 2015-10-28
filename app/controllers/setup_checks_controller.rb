class SetupChecksController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository

  def show
    if @repository.setup?
      render text: url_for([@website, @repository.branch(current_user)])
    else
      render text: ''
    end
  end
end