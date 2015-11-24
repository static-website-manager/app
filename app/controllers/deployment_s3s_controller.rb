class DeploymentS3sController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  before_action only: %i[new create] do
    @deployment = @website.deployments.new(branch_name: @branch.name, type: 'Deployment::S3')
  end

  before_action only: %i[edit update delete destroy] do
    @deployment = @website.deployments.find_by_type_and_branch_name!('Deployment::S3', @branch.name)
  end

  def create
    @deployment.assign_attributes(s3_deployment_params)

    if @deployment.save
      JekyllBuildJob.perform_later(@website, @branch.name, @branch.commit_id)
      redirect_to session[:return_to] || [@website, @branch], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :new, status: 422
    end
  end

  def update
    if @deployment.update(s3_deployment_params)
      JekyllBuildJob.perform_later(@website, @branch.name, @branch.commit_id)
      redirect_to session[:return_to] || [@website, @branch], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :edit, status: 422
    end
  end

  def destroy
    if @deployment.destroy
      redirect_to session[:return_to] || [@website, @branch], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :delete, status: 422
    end
  end

  private

  def s3_deployment_params
    params.require(:deployment_s3).permit(
      :aws_access_key_id,
      :aws_region,
      :aws_s3_bucket,
      :aws_secret_access_key,
    )
  end
end
