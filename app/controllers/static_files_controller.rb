class StaticFilesController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to, only: %i[index show]

  before_action only: %i[show delete destroy] do
    @static_file = StaticFile.find(@repository.rugged_repository, @branch.commit_id, params[:id], @branch.page_extensions)
  end

  def index
    @static_files = StaticFile.all(@repository.rugged_repository, @branch.commit_id, @branch.page_extensions)
  end

  def show
    @commits = Commit.all(@repository.rugged_repository, @branch.commit_id, pathname: @static_file.full_pathname, per_page: 10)
  end

  def destroy
    commit_message = params[:message].present? ? params[:message] : 'Remove File'

    if @static_file.destroy(@branch.name, current_user.email, current_user.name, commit_message, @deployment)
      redirect_to [@website, @branch, :static_files], notice: 'Ok, we‘ve committed your changes.'
    else
      flash.now.alert = 'There was a problem saving your changes.'
      render :delete, status: 422
    end
  end
end
