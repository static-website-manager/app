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
    commit_message = params[:message].present? ? params[:message] : t('.message', filename: @draft.filename_was)
    publication_date = Date.new(params[:publication_year].to_i, params[:publication_month].to_i, params[:publication_day].to_i)
    @draft.full_pathname = ['_posts/', @draft.pathname.sub(/\A_drafts\//, ''), [publication_date.strftime('%Y-%m-%d'), @draft.filename].join('-')].reject(&:blank?).join('/')

    if @draft.save(@branch.name, current_user.email, current_user.name, commit_message, @deployment)
      redirect_to website_branch_post_path(@website, @branch, @draft.pretty_post_pathname), notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :new, status: 422
    end
  end
end
