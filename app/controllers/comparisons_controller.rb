class ComparisonsController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  before_action do
    @target = @website.branch(params[:id] == 'working' ? current_user : params[:id])
    raise ActiveRecord::RecordNotFound if @target.name == @branch.name
  end

  def show
    @diff = @target.target.diff(@branch.target)
  end
end
