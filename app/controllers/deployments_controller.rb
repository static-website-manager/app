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
    @deployment = @website.deployments.find(params[:id])
  end

  def create
    if @deployment.save
      redirect_to session[:return_to] || [@website, @branch], notice: 'Great, we’ve setup a public URL for this branch.'
    else
      flash.not.alert = 'There was a problem publishing this branch.'
      render :new, status: 422
    end
  end

  def destroy
    if @deployment.destroy
      redirect_to session[:return_to] || [@website, @branch], notice: 'Ok, we’ve removed the public URL for this branch.'
    else
      flash.not.alert = 'There was a problem removing the public URL for this branch.'
      render :delete, status: 422
    end
  end
end
