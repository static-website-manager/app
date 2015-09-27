class DraftCommitsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to

  before_action do
    @draft = @branch.find_draft(params[:draft_id])
  end

  def index
    @commits = Commit.list(@repository.send(:rugged_repository), @branch.target, pathname: @draft.full_pathname, page: params[:page])
  end
end
