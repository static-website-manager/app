class PostMovesController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  before_action do
    @post = Post.find(@repository.rugged_repository, @branch.commit_id, params[:post_id], @branch.page_extensions)
  end

  def create
    commit_message = params[:message].present? ? params[:message] : t('.message', filename: @post.filename_was)
    @post.full_pathname = [params[:post].try(:[], :basepath), params[:post].try(:[], :extension)].reject(&:blank?).join('.')

    if @post.save(@branch.name, current_user.email, current_user.name, commit_message)
      JekyllBuildJob.perform_later(@deployment) if @deployment
      redirect_to [@website, @branch, @post], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :new, status: 422
    end
  end
end
