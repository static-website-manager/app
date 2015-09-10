class BlobCommitsController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  before_action do
    @blob = @branch.find_blob(nil, params[:blob_id])
  end

  def index
    @commits = @blob.commits(@branch.target, page: params[:page])
    session[:return_to] = request.path
  end
end
