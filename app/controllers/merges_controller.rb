class MergesController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  before_action do
    @target = @repository.branch('master')

    if @target.production? && !current_authorization.production_branch_access?
      raise ActiveRecord::RecordNotFound
    elsif @target.staging? && @target.user != current_user && !current_authorization.staging_branch_access?
      raise ActiveRecord::RecordNotFound
    elsif @target.custom? && !current_authorization.custom_branch_access?
      raise ActiveRecord::RecordNotFound
    end

    unless @branch.merge_possible?(@target)
      redirect_to [@website, @branch]
    end
  end

  before_action do
    @merge_index = @branch.merge_commits(@target)
  end

  before_action only: %i[create] do
    if @merge_index.conflicts?
      redirect_to [:new, @website, @branch, :merge], alert: 'We are unable to process merge conflicts at this time.'
    end
  end

  def create
    commit_message = params[:message].present? ? params[:message] : "Merge #{@branch.title(current_user)} Changes"

    if @branch.merge(@target, current_user.email, current_user.name, commit_message)
      if deployment = @website.deployments.find_by_branch_name(@target.name)
        JekyllBuildJob.perform_later(deployment)
      end
      redirect_to [@website, @branch], notice: "Great, we’ve successfully merged #{@branch.title(current_user)} changes."
    else
      flash.now.alert = "There was a problem merging #{@branch.title(current_user)} changes."
    end
  end
end
