class BranchesController < ApplicationController
  before_action :require_user

  before_action do
    @website = current_user.websites.find(params[:website_id])
  end

  def show
    @branch = @website.repository.branches.find do |branch|
      branch.refname == params[:id]
    end

    raise ActiveRecord::RecordNotFound unless @branch
  end
end
