class DatasetsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_editor_or_designer
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to

  def index
    @datasets = Dataset.all(@repository.rugged_repository, @branch.commit_id)
  end

  def show
    @dataset = Dataset.find(@repository.rugged_repository, @branch.commit_id, params[:id])
  end
end
