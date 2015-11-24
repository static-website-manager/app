class PagesController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_editor_or_designer
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to, only: %i[index show]

  before_action only: %i[new create] do
    @page = Page.new(rugged_repository: @repository.rugged_repository)
  end

  before_action only: %i[show edit update delete destroy] do
    @page = Page.find(@repository.rugged_repository, @branch.commit_id, params[:id], @branch.page_extensions)
  end

  def index
    @pages = Page.all(@repository.rugged_repository, @branch.commit_id, @branch.page_extensions)
  end

  def create
    commit_message = params[:message].present? ? params[:message] : t('.message')
    @page.full_pathname = [params[:page].try(:[], :basepath), params[:page].try(:[], :extension)].reject(&:blank?).join('.')

    if @page.save(@branch.name, current_user.email, current_user.name, commit_message)
      JekyllBuildJob.perform_later(@website, @branch.name, @branch.commit_id)
      redirect_to [:edit, @website, @branch, @page], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :new, status: 422
    end
  end

  def show
    @commits = Commit.all(@repository.rugged_repository, @branch.commit_id, pathname: @page.full_pathname, per_page: 10)
  end

  def update
    commit_message = params[:message].present? ? params[:message] : t('.message', filename: @page.full_pathname)
    @page.content = params[:page].try(:[], :content)
    @page.metadata = params[:page].try(:[], :metadata)

    if @page.unchanged?
      redirect_to [@website, @branch, @page], alert: t('.alert_unchanged')
    elsif @page.save(@branch.name, current_user.email, current_user.name, commit_message)
      JekyllBuildJob.perform_later(@website, @branch.name, @branch.commit_id)
      redirect_to [@website, @branch, @page], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :edit, status: 422
    end
  end

  def destroy
    commit_message = params[:message].present? ? params[:message] : t('.message', filename: @page.full_pathname)

    if @page.destroy(@branch.name, current_user.email, current_user.name, commit_message)
      JekyllBuildJob.perform_later(@website, @branch.name, @branch.commit_id)
      redirect_to [@website, @branch, :pages], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :delete, status: 422
    end
  end
end
