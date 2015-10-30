class BranchesController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to

  def show
    @commits = Commit.all(@repository.rugged_repository, @branch.commit_id, per_page: 10)
  end

  def destroy
    begin
      ActiveRecord::Base.transaction do
        @deployment.destroy if @deployment
        @repository.delete_branch(@branch.name)
      end
      redirect_to [@website, @repository.branch(current_user)], notice: t('.notice')
    rescue
      flash.now.alert = t('.alert')
      render :delete, status: 422
    end
  end
end
