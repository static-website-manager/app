class StaticFileDownloadsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  before_action do
    @static_file = StaticFile.find(@repository.rugged_repository, @branch.commit_id, params[:static_file_id])
  end

  def show
    send_data @static_file.raw_content, filename: @static_file.filename
  end
end
