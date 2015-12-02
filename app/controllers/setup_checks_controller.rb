class SetupChecksController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository

  def show
    if @repository.setup?
      flash.notice = t('.notice')
      render text: website_branch_path(@website, @repository.branch(current_user))
    else
      render text: ''
    end
  end
end
