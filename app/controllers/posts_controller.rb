class PostsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to, only: %i[index show]

  before_action only: %i[new create] do
    @post = Post.new(rugged_repository: @repository.rugged_repository)
  end

  before_action only: %i[show edit update delete destroy] do
    @post = Post.find(@repository.rugged_repository, @branch.commit_id, params[:id], @branch.page_extensions)
  end

  def index
    @posts = Post.all(@repository.rugged_repository, @branch.commit_id, @branch.page_extensions, page: params[:page], per_page: 50)
  end

  def create
    commit_message = params[:message].present? ? params[:message] : t('.message')
    publication_date = Date.new(params[:publication_year].to_i, params[:publication_month].to_i, params[:publication_day].to_i)
    pathname = params[:post].try(:[], :basepath).to_s.split('/')[0..-2].join('/')
    filename = [params[:post].try(:[], :basepath).to_s.split('/').last, params[:post].try(:[], :extension)].reject(&:blank?).join('.')
    @post.full_pathname = ['_posts', pathname, [publication_date.strftime('%Y-%m-%d'), filename].reject(&:blank?).join('-')].reject(&:blank?).join('/')

    if @post.save(@branch.name, current_user.email, current_user.name, commit_message)
      JekyllBuildJob.perform_later(@deployment) if @deployment
      redirect_to [:edit, @website, @branch, @post], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :new, status: 422
    end
  end

  def show
    @commits = Commit.all(@repository.rugged_repository, @branch.commit_id, pathname: @post.full_pathname, per_page: 10)
  end

  def update
    commit_message = params[:message].present? ? params[:message] : t('.message', filename: @post.pretty_pathname)
    @post.content = params[:post].try(:[], :content)
    @post.metadata = params[:post].try(:[], :metadata)

    if @post.unchanged?
      redirect_to [@website, @branch, @post], alert: t('.alert_unchanged')
    elsif @post.save(@branch.name, current_user.email, current_user.name, commit_message)
      JekyllBuildJob.perform_later(@deployment) if @deployment
      redirect_to [@website, @branch, @post], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :edit, status: 422
    end
  end

  def destroy
    commit_message = params[:message].present? ? params[:message] : t('.message', filename: @post.pretty_pathname)

    if @post.destroy(@branch.name, current_user.email, current_user.name, commit_message)
      JekyllBuildJob.perform_later(@deployment) if @deployment
      redirect_to [@website, @branch, :posts], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :delete, status: 422
    end
  end
end
