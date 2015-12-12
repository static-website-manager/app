class MergesController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  before_action do
    @target = @repository.branch('master')

    unless @branch.merge_possible?(@target)
      redirect_to [@website, @branch]
    end
  end

  before_action only: %i[new create] do
    if @target.production? && !current_authorization.production_branch_access?
      raise ActiveRecord::RecordNotFound
    elsif @target.staging? && @target.user != current_user && !current_authorization.staging_branch_access?
      raise ActiveRecord::RecordNotFound
    elsif @target.custom? && !current_authorization.custom_branch_access?
      raise ActiveRecord::RecordNotFound
    end
  end

  before_action only: %i[new create] do
    @merge_index = @branch.merge_commits(@target)
  end

  before_action only: %i[create] do
    if @merge_index.conflicts?
      redirect_to [:new, @website, @branch, :merge], alert: t('.conflict')
    end
  end

  def create
    commit_message = params[:message].present? ? params[:message] : t('.message', branch_name: @branch.title(current_user))
    merge_behavior = %w[squash_and_set].include?(params[:merge_behavior]) ? params[:merge_behavior] : 'keep_and_merge'

    if @branch.merge(@target, merge_behavior, current_user.email, current_user.name, commit_message)
      @target = @repository.branch(@target.name)
      JekyllBuildJob.perform_later(@website, @target.name, @target.commit_id)
      redirect_to [@website, @branch], notice: t('.notice', branch_name: @branch.title(current_user))
    else
      flash.now.alert = t('.alert', branch_name: @branch.title(current_user))
      render :new
    end
  end

  def destroy
    if @branch.remove_since(@target.commit_id)
      @branch = @repository.branch(@branch.name)
      JekyllBuildJob.perform_later(@website, @branch.name, @branch.commit_id)
      redirect_to [@website, @branch], notice: t('.notice', branch_name: @branch.title(current_user))
    else
      flash.now.alert = t('.alert', branch_name: @branch.title(current_user))
      render :delete
    end
  end
end
