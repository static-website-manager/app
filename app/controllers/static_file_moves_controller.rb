class StaticFileMovesController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_editor_or_designer
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  before_action do
    @static_file = StaticFile.find(@repository.rugged_repository, @branch.commit_id, params[:static_file_id], @branch.page_extensions)
  end

  def create
    commit_message = params[:message].present? ? params[:message] : t('.message', filename: @static_file.filename_was)
    @static_file.full_pathname = [params[:static_file].try(:[], :basepath), params[:static_file].try(:[], :extension)].reject(&:blank?).join('.')

    if @static_file.save(@branch.name, current_user.email, current_user.name, commit_message)
      JekyllBuildJob.perform_later(@website, @branch.name, @branch.commit_id)
      redirect_to [@website, @branch, @static_file], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :new, status: 422
    end
  end
end
