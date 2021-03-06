class StaticFilesController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_editor_or_designer
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
    commit_message = params[:message].present? ? params[:message] : t('.message', filename: @static_file.full_pathname)

    if @static_file.destroy(@branch.name, current_user.email, current_user.name, commit_message)
      JekyllBuildJob.perform_later(@website, @branch.name, @branch.commit_id)
      redirect_to [@website, @branch, :static_files], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :delete, status: 422
    end
  end
end
