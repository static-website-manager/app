class StaticFileMovesController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  before_action do
    @static_file = StaticFile.find(@repository.rugged_repository, @branch.commit_id, params[:static_file_id])
  end

  def create
    if @static_file.move(filename, @branch.name, current_user.email, current_user.name, params[:message])
      redirect_to [@website, @branch, @static_file], notice: 'Great, we’ve committed your changes.'
    else
      flash.now.alert = 'There was a problem saving your changes.'
      render :new, status: 422
    end
  end

  private

  def filename
    [params[:static_file].try(:[], :basename).to_s, @static_file.extension].reject(&:blank?).join('.')
  end
end
