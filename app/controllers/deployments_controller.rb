class DeploymentsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  before_action only: %i[new create] do
    @deployment = @website.deployments.new(branch_name: @branch.name)
  end

  before_action only: %i[delete destroy] do
    @deployment = @website.deployments.find_by_branch_name!(@branch.name)
  end

  def create
    if @deployment.save
      JekyllBuildJob.perform_later(@deployment)
      redirect_to session[:return_to] || [@website, @branch], notice: t('.notice')
    else
      flash.not.alert = t('.alert')
      render :new, status: 422
    end
  end

  def destroy
    if @deployment.destroy
      redirect_to session[:return_to] || [@website, @branch], notice: t('.notice')
    else
      flash.not.alert = t('.alert')
      render :delete, status: 422
    end
  end
end
