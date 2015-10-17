class PageMovesController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  before_action do
    @page = Page.find(@repository.rugged_repository, @branch.commit_id, params[:page_id], @branch.page_extensions)
  end

  def create
    if @page.move(filename, @branch.name, current_user.email, current_user.name, params[:message])
      redirect_to [@website, @branch, @page], notice: 'Great, we’ve committed your changes.'
    else
      flash.now.alert = 'There was a problem saving your changes.'
      render :new, status: 422
    end
  end

  private

  def filename
    [params[:page].try(:[], :basepath).to_s, params[:page].try(:[], :extension).to_s].reject(&:blank?).join('.')
  end
end
