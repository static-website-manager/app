class CheckoutsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  def create
    if params[:target].blank?
      flash.now.alert = 'Please provide a custom branch name.'
      render :new, status: 422
    elsif !@repository.local_branch?(@branch.name)
      flash.now.alert = 'Source branch must already be a local branch.'
      render :new, status: 422
    elsif params[:target].match(/\A(static_user|master)/)
      flash.now.alert = 'Custom branch must not be the production branch (master) or a Static Website Manager staging branch.'
      render :new, status: 422
    elsif @repository.local_branch?(params[:target])
      flash.now.alert = 'Custom branch must not already be a local branch.'
      render :new, status: 422
    else
      begin
        @repository.create_branch(@branch.name, params[:target])

        if params[:deploy]
          @website.deployments.create(branch_name: params[:target])
        end

        redirect_to [@website, @repository.branch(params[:target])], notice: 'Ok, your new branch is ready to use.'
      rescue Rugged::ReferenceError => e
        @error_message = true
        flash.now.alert = e.message
        render :new, status: 422
      end
    end
  end
end
