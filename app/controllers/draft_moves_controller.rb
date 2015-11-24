class DraftMovesController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  before_action do
    @draft = Draft.find(@repository.rugged_repository, @branch.commit_id, params[:draft_id], @branch.page_extensions)
  end

  def create
    commit_message = params[:message].present? ? params[:message] : t('.message', filename: @draft.filename_was)
    @draft.full_pathname = [params[:draft].try(:[], :basepath), params[:draft].try(:[], :extension)].reject(&:blank?).join('.')

    if @draft.save(@branch.name, current_user.email, current_user.name, commit_message)
      JekyllBuildJob.perform_later(@website, @branch.name, @branch.commit_id)
      redirect_to [@website, @branch, @draft], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :new, status: 422
    end
  end
end
