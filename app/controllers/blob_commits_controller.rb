class BlobCommitsController < ApplicationController
  include WebsiteConcern
  include BranchConcern

  before_action do
    @blob = @branch.find_blob(nil, params[:blob_id])
  end

  def index
    @commits = @blob.commits(@branch.target, page: params[:page])
  end
end
