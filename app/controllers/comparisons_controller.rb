class ComparisonsController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  before_action do
    @target = @website.branch(params[:id] == 'working' ? current_user : params[:id])
    raise ActiveRecord::RecordNotFound if @target.name == @branch.name
  end

  def show
    @merge_base = @website.merge_base(@branch.target, @target.target)
  end
end
