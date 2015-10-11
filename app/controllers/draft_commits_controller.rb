class DraftCommitsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to

  before_action do
    @draft = Draft.find(@repository.rugged_repository, @branch.commit_id, params[:draft_id])
  end

  def index
    @commits = Commit.all(@repository.rugged_repository, @branch.commit_id, pathname: @draft.full_pathname, page: params[:page])
  end
end
