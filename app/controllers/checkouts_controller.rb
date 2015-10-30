class CheckoutsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  before_action do
    unless current_authorization.custom_branch_access?
      redirect_to [@website, @branch]
    end
  end

  def create
    if params[:target].blank?
      flash.now.alert = t('.alert_blank')
      render :new, status: 422
    elsif !@repository.local_branch?(@branch.name)
      flash.now.alert = t('.alert_missing')
      render :new, status: 422
    elsif params[:target].match(/\A(static_user|master)/)
      flash.now.alert = t('.alert_ours')
      render :new, status: 422
    elsif @repository.local_branch?(params[:target])
      flash.now.alert = t('.alert_same')
      render :new, status: 422
    else
      begin
        @repository.create_branch(@branch.name, params[:target])

        if params[:deploy]
          JekyllBuildJob.perform_later(@website.deployments.create!(branch_name: params[:target]))
        end

        redirect_to [@website, @repository.branch(params[:target])], notice: t('.notice')
      rescue Rugged::ReferenceError => e
        @error_message = true
        flash.now.alert = e.message
        render :new, status: 422
      rescue
        flash.now.alert = t('.alert')
        render :new, status: 422
      end
    end
  end
end
