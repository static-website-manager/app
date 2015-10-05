class PostMovesController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  before_action do
    @post = Post.find(@repository.send(:rugged_repository), @branch.commit_id, params[:post_id])
  end

  def create
    if @post.move(filename, @branch.name, current_user.email, current_user.name, params[:message])
      redirect_to [@website, @branch, @post], notice: 'Great, we’ve committed your changes.'
    else
      flash.now.alert = 'There was a problem saving your changes.'
      render :new, status: 422
    end
  end

  private

  def filename
    [params[:post].try(:[], :basename).to_s, params[:post].try(:[], :extension).to_s].reject(&:blank?).join('.')
  end
end
