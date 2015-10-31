class RebasesController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  before_action do
    @source = @repository.branch('master')

    unless @branch.rebase_required?(@source)
      redirect_to [@website, @branch]
    end
  end

  before_action do
    @merge_index = @branch.merge_commits(@source)
  end

  before_action only: %i[create] do
    if @merge_index.conflicts?
      redirect_to [:new, @website, @branch, :rebase], alert: t('.conflict')
    end
  end

  def create
    if @branch.rebase(@source)
      JekyllBuildJob.perform_later(@deployment) if @deployment
      redirect_to [@website, @branch], notice: t('.notice', branch_name: @source.title(current_user))
    else
      flash.now.alert = t('.alert', branch_name: @source.title(current_user))
      render :new, status: 422
    end
  end
end
