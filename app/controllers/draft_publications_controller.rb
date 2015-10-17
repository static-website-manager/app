class DraftPublicationsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  before_action do
    @draft = Draft.find(@repository.rugged_repository, @branch.commit_id, params[:draft_id], @branch.page_extensions)
  end

  def create
    if @draft.publish(publication_date, @branch.name, current_user.email, current_user.name, params[:message])
      redirect_to website_branch_post_path(@website, @branch, @draft), notice: 'Great, we’ve committed your changes.'
    else
      flash.now.alert = 'There was a problem saving your changes.'
      render :new, status: 422
    end
  end

  private

  def publication_date
    Date.new(params[:publication_year].to_i, params[:publication_month].to_i, params[:publication_day].to_i)
  end
end
