class CommitsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_setup_repository

  def show
    @commit = @website.commit(params[:id])
  end
end
