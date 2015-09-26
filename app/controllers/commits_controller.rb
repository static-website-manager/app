class CommitsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup

  def show
    @commit = @repository.commit(params[:id])
  end
end
