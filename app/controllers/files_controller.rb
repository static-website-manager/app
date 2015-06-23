class FilesController < ApplicationController
  before_action :require_user

  before_action do
    @website = current_user.websites.find(params[:website_id])
    @branch = @website.repository.branches.find do |branch|
      branch.refname == params[:branch_id]
    end

    raise ActiveRecord::RecordNotFound unless @branch
  end

  def index
  end
end
