class RestoresController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  before_action do
    @commit = @repository.commit(params[:commit_id])
  end

  def create
    commit_message = params[:message].present? ? params[:message] : t('.message', commit_id: @commit.id[0..6])

    if @branch.restore(@commit.id, current_user.email, current_user.name, commit_message)
      @branch = @repository.branch(@branch.name)
      JekyllBuildJob.perform_later(@website, @branch.name, @branch.commit_id)
      redirect_to session[:return_to] || [@website, @branch], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :new
    end
  end
end
