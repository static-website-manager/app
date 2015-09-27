class PagesController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to, only: %i[index show]

  before_action only: %i[show edit update] do
    @page = Page.find(@repository.send(:rugged_repository), @branch.commit_id, params[:id])
  end

  def index
    @pages = Page.all(@repository.send(:rugged_repository), @branch.commit_id)
  end

  def new
  end

  def create
  end

  def show
    @commits = Commit.all(@repository.send(:rugged_repository), @branch.commit_id, pathname: @page.full_pathname, per_page: 10)
  end

  def edit
  end

  def update
    new_id = @page.save(@website, @branch, current_user, page_content, params[:message])

    if new_id.present? && new_id == @page.id
      redirect_to website_branch_page_path(@website, @branch, @page), alert: 'No changes detected.'
    elsif new_id.present?
      redirect_to website_branch_page_path(@website, @branch, new_id), notice: 'Great, we’ve committed your changes.'
    else
      flash.now.alert = 'There was a problem saving your changes.'
      render :edit, status: 422
    end
  end

  private

  def page_content
    if params[:page].try(:[], :metadata).present?
      [YAML.dump(params[:page][:metadata].to_hash), @page.writable? ? params[:page].try(:[], :content) || '' : @page.content].join("---\n\n")
    else
      @page.writable? ? params[:page].try(:[], :content) || '' : @page.content
    end
  end
end
