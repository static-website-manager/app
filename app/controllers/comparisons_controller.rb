class ComparisonsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_setup_repository
  before_action :require_branch

  before_action do
    @target = @website.branch(params[:id] == 'working' ? current_user : params[:id])
    raise ActiveRecord::RecordNotFound if @target.name == @branch.name
    @merge_base = @repository.merge_base(@branch.target, @target.target)
  end

  def merge
    if @branch.target.oid == @target.target.oid
      redirect_to [@website, @branch, @target], alert: 'These branches are up-to-date. No merge is necessary.'
    elsif @branch.target.oid == @merge_base
      @repository.update_ref("refs/heads/#{@branch.raw_name}", @target.target.oid)
      redirect_to [@website, @branch, @target], notice: 'Great, these branches are now up-to-date.'
    elsif @target.target.oid == @merge_base
      @repository.update_ref("refs/heads/#{@target.raw_name}", @branch.target.oid)
      redirect_to [@website, @branch, @target], notice: 'Great, these branches are now up-to-date.'
    else
      redirect_to [@website, @branch, @target], alert: 'These branches have diverged and must be merged offline.'
    end
  end
end
