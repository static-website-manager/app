class CheckoutsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  def create
    if params[:target].blank?
      flash.now.alert = 'Please provide a target branch.'
      render :new, status: 422
    elsif !@repository.local_branch?(@branch.raw_name)
      flash.now.alert = 'Source branch must already be a local branch.'
      render :new, status: 422
    elsif params[:target].match(/\A(swm_user|master)/)
      flash.now.alert = 'Target branch must not be the master or a Static Website Manager branch.'
      render :new, status: 422
    elsif @repository.local_branch?(params[:target])
      flash.now.alert = 'Target branch must not already be a local branch.'
      render :new, status: 422
    elsif @repository.create_branch(@branch.raw_name, params[:target])
      redirect_to [@website, @repository.branch(params[:target])], notice: 'Ok, your new branch is ready to use.'
    else
      flash.now.alert = 'There was a problem creating your branch.'
      render :new, status: 422
    end
  end
end
