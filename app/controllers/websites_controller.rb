class WebsitesController < ApplicationController
  before_action :require_user
  before_action :require_website, only: %i[show]
  before_action :require_repository, only: %i[show]
  before_action :set_return_to, only: %i[index]

  before_action only: %i[show] do
    @repository = Repository.new(website_id: website_id)
  end

  def index
    @websites = current_user.websites
  end

  def show
    if @repository.setup?
      redirect_to [@website, @repository.branch(current_user)]
    else
      redirect_to [:new, @website, :setup]
    end
  end
end
