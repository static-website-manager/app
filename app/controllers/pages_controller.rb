class PagesController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to, only: %i[index show]

  before_action only: %i[new create] do
    @page = Page.new(rugged_repository: @repository.send(:rugged_repository))
  end

  before_action only: %i[show edit update] do
    @page = Page.find(@repository.send(:rugged_repository), @branch.commit_id, params[:id])
  end

  def index
    @pages = Page.all(@repository.send(:rugged_repository), @branch.commit_id)
  end

  def create
    if success
      redirect_to website_branch_page_path(@website, @branch, @page), notice: 'Great, we’ve committed your changes.'
    else
      flash.now.alert = 'There was a problem saving your changes.'
      render :edit, status: 422
    end
  end

  def show
    @commits = Commit.all(@repository.send(:rugged_repository), @branch.commit_id, pathname: @page.full_pathname, per_page: 10)
  end

  def update
    raw_content = @page.raw_content
    @page.content = params[:page].try(:[], :content)
    @page.filename = params[:page].try(:[], :filename)
    @page.metadata = params[:page].try(:[], :metadata)

    if @page.raw_content == raw_content
      redirect_to [@website, @branch, @page], alert: 'No changes detected.'
    elsif @page.save(@branch.name, current_user.email, current_user.name, params[:message])
      redirect_to [@website, @branch, @page], notice: 'Great, we’ve committed your changes.'
    else
      flash.now.alert = 'There was a problem saving your changes.'
      render :edit, status: 422
    end
  end
end
