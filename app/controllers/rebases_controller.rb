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
      redirect_to [:new, @website, @branch, :rebase], alert: 'We are unable to process changes with conflicts at this time.'
    end
  end

  def create
    if @branch.rebase(@source, current_user.email, current_user.name)
      JekyllBuildJob.perform_later(@deployment) if @deployment
      redirect_to [@website, @branch], notice: "Great, we’ve successfully pulled in #{@source.title(current_user)} changes."
    else
      flash.now.alert = "There was a problem pulling #{@source.title(current_user)} changes."
      render :new, status: 422
    end
  end
end
