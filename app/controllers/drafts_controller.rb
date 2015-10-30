class DraftsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to, only: %i[index show]

  before_action only: %i[new create] do
    @draft = Draft.new(rugged_repository: @repository.rugged_repository)
  end

  before_action only: %i[show edit update delete destroy] do
    @draft = Draft.find(@repository.rugged_repository, @branch.commit_id, params[:id], @branch.page_extensions)
  end

  def index
    @drafts = Draft.all(@repository.rugged_repository, @branch.commit_id, @branch.page_extensions, page: params[:page], per_page: 12)
  end

  def create
    commit_message = params[:message].present? ? params[:message] : t('.message')
    @draft.full_pathname = [['_drafts', params[:draft].try(:[], :basepath)].reject(&:blank?).join('/'), params[:draft].try(:[], :extension)].reject(&:blank?).join('.')

    if @draft.save(@branch.name, current_user.email, current_user.name, commit_message, @deployment)
      redirect_to [:edit, @website, @branch, @draft], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :new, status: 422
    end
  end

  def show
    @commits = Commit.all(@repository.rugged_repository, @branch.commit_id, pathname: @draft.full_pathname, per_page: 10)
  end

  def update
    commit_message = params[:message].present? ? params[:message] : t('.message', filename: @draft.pretty_pathname)
    @draft.content = params[:draft].try(:[], :content)
    @draft.metadata = params[:draft].try(:[], :metadata)

    if @draft.unchanged?
      redirect_to [@website, @branch, @draft], alert: t('.alert_unchanged')
    elsif @draft.save(@branch.name, current_user.email, current_user.name, commit_message, @deployment)
      redirect_to [@website, @branch, @draft], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :edit, status: 422
    end
  end

  def destroy
    commit_message = params[:message].present? ? params[:message] : t('.message', filename: @draft.pretty_pathname)

    if @draft.destroy(@branch.name, current_user.email, current_user.name, commit_message, @deployment)
      redirect_to [@website, @branch, :drafts], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :delete, status: 422
    end
  end
end
