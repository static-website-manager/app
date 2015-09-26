class DraftCommitsController < ApplicationController
  include WebsiteConcern
  include BranchConcern

  before_action do
    @draft = @branch.find_draft(params[:draft_id])
  end

  def index
    @commits = @draft.commits(@branch.target, page: params[:page])
  end
end