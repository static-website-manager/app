class BranchesController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to

  def show
    @commits = Commit.all(@repository.rugged_repository, @branch.commit_id, per_page: 10)
    @datasets = Dataset.all(@repository.rugged_repository, @branch.commit_id, per_page: 1)
    @deployments = @website.deployments.where(branch_name: @branch.name)
    @form_responders = @website.form_responders.where(branch_name: @branch.name)
  end

  def destroy
    if @repository.delete_branch(@branch.name)
      # TODO: Remove /website dir
      redirect_to [@website, @repository.branch(current_user)], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :delete, status: 422
    end
  end
end
