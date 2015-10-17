class StaticFilePreviewsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  before_action do
    @static_file = StaticFile.find(@repository.rugged_repository, @branch.commit_id, params[:static_file_id], @branch.page_extensions)
  end

  def show
    unless @static_file.preview?
      redirect_to [@website, @branch, @static_file]
    end
  end
end
