class BranchCommitsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to, only: %i[index]

  before_action only: %i[show delete destroy] do
    @commit = @repository.commit(params[:id])
  end

  def index
    @commits = Commit.all(@repository.rugged_repository, @branch.commit_id, page: params[:page])
  end

  def destroy
    if @branch.remove(@commit.id)
      @branch = @repository.branch(@branch.name)
      JekyllBuildJob.perform_later(@website, @branch.name, @branch.commit_id)
      redirect_to session[:return_to] || [@website, @branch], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :delete
    end
  end
end
