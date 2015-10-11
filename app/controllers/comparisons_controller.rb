class ComparisonsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  before_action do
    @target = @repository.branch(params[:id] == 'working' ? current_user : params[:id])
    raise ActiveRecord::RecordNotFound if @target.name == @branch.name
    @merge_base = @repository.merge_base(@branch.commit_id, @target.commit_id)
  end

  def show
    @branch_commits = Commit.all(@repository.rugged_repository, @branch.commit_id, per_page: 3)
    @target_commits = Commit.all(@repository.rugged_repository, @target.commit_id, per_page: 3)
  end

  def merge
    if @branch.commit_id == @target.commit_id
      redirect_to [@website, @branch, @target], alert: 'These branches are up-to-date. No merge is necessary.'
    elsif @branch.commit_id == @merge_base
      @repository.update_ref("refs/heads/#{@branch.name}", @target.commit_id)
      redirect_to [@website, @branch, @target], notice: 'Great, these branches are now up-to-date.'
    elsif @target.commit_id == @merge_base
      @repository.update_ref("refs/heads/#{@target.name}", @branch.commit_id)
      redirect_to [@website, @branch, @target], notice: 'Great, these branches are now up-to-date.'
    else
      redirect_to [@website, @branch, @target], alert: 'These branches have diverged and must be merged offline.'
    end
  end
end
