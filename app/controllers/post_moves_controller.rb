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
    commit_message = params[:message].present? ? params[:message] : 'Move Post'
    @post.full_pathname = [params[:post].try(:[], :basepath), params[:post].try(:[], :extension)].reject(&:blank?).join('.')

    if @post.move(@branch.name, current_user.email, current_user.name, commit_message, @deployment)
      redirect_to [@website, @branch, @post], notice: 'Great, we’ve committed your changes.'
    else
      flash.now.alert = 'There was a problem saving your changes.'
      render :new, status: 422
    end
  end
end
